import 'salami_unlock_platform_interface.dart';

class SalamiUnlock {
  Future<String?> getPlatformVersion() {
    return SalamiUnlockPlatform.instance.getPlatformVersion();
  }

  Future<void> require({String? message, void Function(bool)? onResult}) async =>
      SalamiUnlockPlatform.instance.requireUnlock(message ?? 'Unlock page').then((authResult) {
        if (onResult != null) onResult(authResult);
      });
}
