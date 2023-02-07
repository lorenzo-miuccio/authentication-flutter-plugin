import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'salami_unlock_platform_impl.dart';
part 'salami_unlock_platform_interface.dart';

/// Flutter plugin for authenticating the user using device credentials.
class SalamiUnlock {
  SalamiUnlock._();

  /// Authenticates the user with biometrics credentials (if available) or using an already
  /// setup pin, pattern, passcode.
  ///
  /// Provide [message] if you want to customize the message shown to user while prompting them
  /// for authentication.
  ///
  /// Provide [onResult] to specify a callback to execute according to the [LocalAuthResult].
  static void require(BuildContext context, {String? message, void Function(LocalAuthResult)? onResult}) =>
      SalamiUnlockPlatform.instance
      .requireUnlock(message)
      .then((nativeAuthResponse) {
        if(context.mounted) onResult?.call(LocalAuthResult._getByNativeResponse(nativeAuthResponse));
      });


  ///Only for android platforms.
  ///
  ///Redirects the user to the local credentials setup page.
  ///
  /// Returns true if the user was correctly redirected to the page, otherwise false.
  /// On iOS platforms returns always false.
  static Future<bool> deviceCredentialsSetup() => SalamiUnlockPlatform.instance.deviceCredentialsSetup();
}

/// Possible results of the authentication process.
enum LocalAuthResult {

  ///The user successfully authenticated.
  success,

  ///The user canceled the authentication process or failed to provide valid credentials.
  failure,

  ///The user can't authenticate because no biometric or device credentials are enrolled.
  ///On android devices you can redirect the user to the credentials setup page calling [SalamiUnlock.deviceCredentialsSetup]
  TBD,

  ///The device doesn't support local authentication feature
  unsupported,

  ///Only for Android devices
  ///The user can't authenticate because a security vulnerability has been discovered with one or more hardware sensors.
  ///The affected sensor(s) are unavailable until a security update has addressed the issue.
  updateNeeded,

  ///Unable to determine whether the user can authenticate.
  unknown;

  static LocalAuthResult _getByNativeResponse(String nativeResponse) {
    switch (nativeResponse.toLowerCase()) {
      case "success":
        return LocalAuthResult.success;
      case "tbd":
        return LocalAuthResult.TBD;
      case "failure":
        return LocalAuthResult.failure;
      case "unsupported":
        return LocalAuthResult.unsupported;
      case "updateNeeded":
        return LocalAuthResult.success;
      default:
        return LocalAuthResult.unknown;
    }
  }
}
