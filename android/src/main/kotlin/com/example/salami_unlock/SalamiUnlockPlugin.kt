package com.example.salami_unlock

import android.app.Activity
import android.app.KeyguardManager
import android.content.Intent

import android.os.Build
import android.provider.Settings
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG
import androidx.biometric.BiometricManager.Authenticators.DEVICE_CREDENTIAL
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.Executor


/** SalamiUnlockPlugin */
class SalamiUnlockPlugin : FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    enum class AuthResult {
        Success,
        Failure
    }

    private lateinit var executor: Executor
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo

    private var requestCode: Int = 0

    private lateinit var channel: MethodChannel

    private var activity: Activity? = null
        set(value) {
            field = value
            requestCode = value?.hashCode() ?: 0
        }

    private var onActivityResultCallback: ((AuthResult) -> Unit)? = null

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    private val methodCallHandler = MethodCallHandler { call, result ->
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "requireUnlock" -> {
                print(AuthResult.Success.name)
                onActivityResultCallback = {
                    result.success(it.name)
                    onActivityResultCallback = null
                }
                requireUnlock(call.argument<String>("message"))
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun requireUnlock(message: String?) {


        activity?.let { activity ->
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                val keyguardManager =
                    activity.getSystemService(Activity.KEYGUARD_SERVICE) as KeyguardManager
                if (keyguardManager.isKeyguardSecure) {
                    val authIntent: Intent = keyguardManager.createConfirmDeviceCredentialIntent(
                        "prova",
                        message ?: "Inserisci codice"
                    )
                    activity.startActivityForResult(authIntent, requestCode)
                }
            } else {
                biometricPrompt = BiometricPrompt(activity, executor,
                    object : BiometricPrompt.AuthenticationCallback() {
                        override fun onAuthenticationError(errorCode: Int,
                                                           errString: CharSequence) {
                            super.onAuthenticationError(errorCode, errString)
                            onActivityResultCallback?.invoke(AuthResult.Success)
                        }

                        override fun onAuthenticationSucceeded(
                            result: BiometricPrompt.AuthenticationResult) {
                            super.onAuthenticationSucceeded(result)
                            onActivityResultCallback?.invoke(AuthResult.Failure)

                        }

                        override fun onAuthenticationFailed() {
                            super.onAuthenticationFailed()
                            onActivityResultCallback?.invoke(AuthResult.Failure)
                        }
                    })
                val promptInfo = BiometricPrompt.PromptInfo.Builder()
                    .setTitle("Biometric login for my app")
                    .setSubtitle("Log in using your biometric credential")
                    .setAllowedAuthenticators(BIOMETRIC_STRONG or DEVICE_CREDENTIAL)
                    .build()
                val biometricManager = BiometricManager.from(activity)
                if (biometricManager.canAuthenticate(BIOMETRIC_STRONG or DEVICE_CREDENTIAL) == BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED) {
                    // Prompts the user to create credentials that your app accepts.
                    val enrollIntent = Intent(Settings.ACTION_BIOMETRIC_ENROLL).apply {
                        putExtra(
                            Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                            BIOMETRIC_STRONG or DEVICE_CREDENTIAL
                        )
                    }
                    activity.startActivityForResult(enrollIntent, requestCode)
                } else {
                    biometricPrompt.authenticate(promptInfo)
                }
            }
        }

    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "salami_unlock")
        channel.setMethodCallHandler(methodCallHandler)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return data.takeIf { requestCode == this.requestCode }
            ?.takeIf { requestCode == Activity.RESULT_OK }
            ?.let {
                onActivityResultCallback?.invoke(AuthResult.Success)
                true
            } ?: false
    }
}
