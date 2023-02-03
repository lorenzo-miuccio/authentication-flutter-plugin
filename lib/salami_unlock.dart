import 'salami_unlock_platform_interface.dart';

class SalamiUnlock {
  SalamiUnlock._();

  static Future<String?> getPlatformVersion() {
    return SalamiUnlockPlatform.instance.getPlatformVersion();
  }

  static Future<void> require({String? message, void Function(LocalAuthResult)? onResult}) =>
      SalamiUnlockPlatform.instance.requireUnlock(message).then((nativeAuthResult) {
        if(onResult != null) onResult(LocalAuthResult._getBy(nativeAuthResult));
      });

  static Future<bool?> deviceCredentialsSetup() =>
      SalamiUnlockPlatform.instance.deviceCredentialsSetup();
}


enum LocalAuthResult {
  success,
  failure,
  TBD,
  unsupported,
  updateNeeded,
  unknown;

  static LocalAuthResult _getBy(String? nativeRensponse) {
    LocalAuthResult authResult;
    switch (nativeRensponse) {
      case "success":
        authResult = LocalAuthResult.success;
        break;
      case "tbd":
        authResult = LocalAuthResult.TBD;
        break;

      case "failure":
        authResult = LocalAuthResult.failure;
        break;

      case "unsupported":
        authResult = LocalAuthResult.unsupported;
        break;

      case "updateNeeded":
        authResult = LocalAuthResult.success;
        break;

      default:
        authResult = LocalAuthResult.unknown;
    }
    return authResult;
  }
}