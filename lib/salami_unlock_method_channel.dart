import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'salami_unlock_platform_interface.dart';

/// An implementation of [SalamiUnlockPlatform] that uses method channels.
class MethodChannelSalamiUnlock extends SalamiUnlockPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('salami_unlock');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> requireUnlock(String? message) =>
      methodChannel.invokeMethod<String>('requireUnlock', {"message": message}).then((value) => value?.toLowerCase());

  @override
  Future<bool?> deviceCredentialsSetup() => methodChannel.invokeMethod<bool>('requireDeviceCredentialsSetup').then((value) {print(value);});
}
