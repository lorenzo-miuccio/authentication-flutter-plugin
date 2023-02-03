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
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import java.lang.Integer.min


/** SalamiUnlockPlugin */
class SalamiUnlockPlugin : FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    enum class AuthResult {
        Success,
        Failure,
        TBD,
        Unsupported,
        UpdateNeeded,
        Unknown
    }

    private var requestCode: Int = 0

    private lateinit var channel: MethodChannel

    private var activity: Activity? = null
        set(value) {
            field = value
            requestCode = value?.hashCode() ?: 0
            requestCode = min(requestCode, Short.MAX_VALUE.toInt()) // max 16 bits
        }

    private var onAuthResultCallback: ((AuthResult) -> Unit)? = null

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
                onAuthResultCallback = {
                    result.success(it.name)
                    onAuthResultCallback = null
                }
                requireUnlock(call.argument<String>("message"))
            }
            "requireDeviceCredentialsSetup" -> {
                val activity = activity

                activity?.packageManager?.let { pm ->
                    fun launchIntent(i: Intent) = if (i.resolveActivity(pm) != null) {
                        activity.startActivityForResult(i, requestCode)
                        result.success(true)
                    } else result.success(false)

                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                        launchIntent(Intent(Settings.ACTION_SECURITY_SETTINGS))
                    } else {
                        launchIntent(Intent(Settings.ACTION_BIOMETRIC_ENROLL).apply {
                            putExtra(
                                Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                                BIOMETRIC_STRONG or DEVICE_CREDENTIAL
                            )
                        })
                    }
                } ?: result.success(false)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun requireUnlock(message: String?) {

        val message = message ?: "Unlock"
        activity?.also { activity ->
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                val keyguardManager =
                    activity.getSystemService(Activity.KEYGUARD_SERVICE) as KeyguardManager
                if (keyguardManager.isKeyguardSecure) {
                    val authIntent: Intent = keyguardManager.createConfirmDeviceCredentialIntent(
                        message,
                        "Log in using your credential"
                    )
                    activity.startActivityForResult(authIntent, requestCode)
                }
            } else {
                val executor = ContextCompat.getMainExecutor(activity)
                val biometricPrompt = BiometricPrompt(activity as FragmentActivity, executor,
                    object : BiometricPrompt.AuthenticationCallback() {
                        override fun onAuthenticationError(
                            errorCode: Int,
                            errString: CharSequence
                        ) {
                            super.onAuthenticationError(errorCode, errString)
                            onAuthResultCallback?.invoke(AuthResult.Failure)
                        }

                        override fun onAuthenticationSucceeded(
                            result: BiometricPrompt.AuthenticationResult
                        ) {
                            super.onAuthenticationSucceeded(result)
                            onAuthResultCallback?.invoke(AuthResult.Success)
                        }

                        override fun onAuthenticationFailed() {
                            super.onAuthenticationFailed()
                            onAuthResultCallback?.invoke(AuthResult.Failure)
                        }
                    })
                val promptInfo = BiometricPrompt.PromptInfo.Builder()
                    .setTitle(message)
                    .setSubtitle("Log in using your biometric credential")
                    .setAllowedAuthenticators(BIOMETRIC_STRONG or DEVICE_CREDENTIAL)
                    .build()
                val biometricManager = BiometricManager.from(activity)

                when (
                    biometricManager.canAuthenticate(BIOMETRIC_STRONG or DEVICE_CREDENTIAL)) {
                    BiometricManager.BIOMETRIC_SUCCESS -> biometricPrompt.authenticate(promptInfo)
                    BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> onAuthResultCallback?.invoke(
                        AuthResult.TBD
                    )
                    BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE,
                    BiometricManager.BIOMETRIC_ERROR_UNSUPPORTED,
                    BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> onAuthResultCallback?.invoke(
                        AuthResult.Unsupported
                    )
                    BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED -> onAuthResultCallback?.invoke(
                        AuthResult.UpdateNeeded
                    )
                    else -> onAuthResultCallback?.invoke(AuthResult.Unknown)
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
        data.takeIf { requestCode == this.requestCode }
            ?.takeIf { resultCode == Activity.RESULT_OK }
            ?.let {
                onAuthResultCallback?.invoke(AuthResult.Success)
                return true
            }
        onAuthResultCallback?.invoke(AuthResult.Failure)
        return false
    }
}
