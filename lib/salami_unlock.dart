import 'salami_unlock_platform_interface.dart';

class SalamiUnlock {
  SalamiUnlock._();

  static Future<String?> getPlatformVersion() {
    return SalamiUnlockPlatform.instance.getPlatformVersion();
  }

  static Future<void> require({String? message, void Function(bool)? onResult}) =>
      SalamiUnlockPlatform.instance.requireUnlock(message).then((authResult) {
        if (onResult != null) onResult(authResult);
      });
}