part of 'salami_unlock.dart';

/// An implementation of [SalamiUnlockPlatform] that uses method channels.
class _SalamiUnlockPlatformImpl extends SalamiUnlockPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('salami_unlock');

  @override
  Future<String> requireUnlock(String? message) =>
      methodChannel.invokeMethod<String>('requireUnlock', {"message": message}).then((value) => value!);

  @override
  Future<bool> deviceCredentialsSetup() =>
      methodChannel.invokeMethod<bool>('requireDeviceCredentialsSetup').then((value) => value!);
}