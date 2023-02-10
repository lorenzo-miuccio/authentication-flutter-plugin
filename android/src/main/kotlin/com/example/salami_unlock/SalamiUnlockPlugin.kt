package com.example.salami_unlock

import android.app.Activity
import android.app.KeyguardManager
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
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
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.lang.Integer.min

/**
 * Implements:
 *
 * - [ActivityAware] because we are interested in Activity lifecycle events
 * related to a FlutterEngine running within the given Activity.
 *
 * - [PluginRegistry.ActivityResultListener] to implement the method [onActivityResult].
 * We get a result back from an activity using the method [Activity.startActivityForResult] to launch it.
 * The result will be handled in [onActivityResult].
 *
 */
class SalamiUnlockPlugin : FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener {

    /// Possible Authentication results to be forwarded to the Flutter caller as String
    enum class AuthResult {
        Success,
        Failure,
        TBD,
        Unsupported,
        UpdateNeeded,
        Unknown
    }

    private var requestCode: Int = 0

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var pluginBinding: ActivityPluginBinding? = null

    private var activity: Activity? = null
        set(value) {
            field = value
            requestCode = value?.hashCode() ?: 0
            requestCode =
                min(requestCode, Short.MAX_VALUE.toInt()) // max 16 bits
        }

    private var onAuthResultCallback: ((AuthResult) -> Unit)? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "salami_unlock")
        channel.setMethodCallHandler(methodCallHandler)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    //Retrieve the activity from the pluginBinding when the activity is connected to the flutter engine
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        pluginBinding = binding

        /**
         * Add this line to ensure to trigger the [onActivityResult] method when
         * an activity returns a result
         */
        pluginBinding?.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activity = null
        pluginBinding?.removeActivityResultListener(this)
        pluginBinding = null
    }

    private val methodCallHandler = MethodCallHandler { call, result ->
        when (call.method) {

            //Method called when flutter requires a local authentication
            "requireUnlock" -> {
                onAuthResultCallback = {
                    result.success(it.name)
                    onAuthResultCallback = null
                }
                requireUnlock(call.argument<String>("message"))
            }

            /**
             * Method called to setup the device credentials for authentication.
             *
             * First checks if the activity can be launched with the setup credentials intent.
             * Returns true to flutter if the activity was launched so the user was redirected to the appropriate settings page,
             * otherwise false
             *
             * The action for the intent [Settings.ACTION_BIOMETRIC_ENROLL] requires Android SDK > 30.
             * The function checks if the requirement is guaranteed, otherwise the action would be
             * [Settings.ACTION_SECURITY_SETTINGS]
             */
            "requireDeviceCredentialsSetup" -> {
                val activity = activity

                activity?.packageManager?.let { pm ->
                    fun launchIntent(i: Intent) = if (i.resolveActivity(pm) != null) {
                        activity.startActivity(i)
                        result.success(true)
                    } else result.success(false)

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        launchIntent(Intent(Settings.ACTION_BIOMETRIC_ENROLL).apply {
                            putExtra(
                                Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                                BIOMETRIC_STRONG or DEVICE_CREDENTIAL
                            )
                        })
                    } else {
                        launchIntent(Intent(Settings.ACTION_SECURITY_SETTINGS))
                    }
                } ?: result.success(false)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Firstly checks if it is possible for the user to authenticate with either biometric sensors or
     * device credentials (pin, password or pattern).
     *
     * Start a new activity with the authentication intent if possible, otherwise returns to flutter
     * the [AuthResult] that corresponds to the error.
     *
     * When the activity is completed the function [onActivityResult] is called
     *
     * Uses [BiometricPrompt] if the device SDK version is >= 30, otherwise [KeyguardManager]
     */
    private fun requireUnlock(message: String?) {

        val message = message ?: "Unlock"
        activity?.also { activity ->
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
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
                    .setSubtitle("Log in using your credentials")
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
            } else {
                val keyguardManager =
                    activity.getSystemService(Activity.KEYGUARD_SERVICE) as KeyguardManager
                if (keyguardManager.isDeviceSecure) {
                    val authIntent: Intent = keyguardManager.createConfirmDeviceCredentialIntent(
                        message,
                        "Log in using your credential"
                    )
                    activity.startActivityForResult(authIntent, requestCode)
                } else {
                    onAuthResultCallback?.invoke(AuthResult.TBD)
                }
            }
        }

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
