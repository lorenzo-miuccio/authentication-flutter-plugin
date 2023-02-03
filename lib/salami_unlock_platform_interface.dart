import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'salami_unlock_method_channel.dart';

abstract class SalamiUnlockPlatform extends PlatformInterface {
  /// Constructs a SalamiUnlockPlatform.
  SalamiUnlockPlatform() : super(token: _token);

  static final Object _token = Object();

  static SalamiUnlockPlatform _instance = MethodChannelSalamiUnlock();

  /// The default instance of [SalamiUnlockPlatform] to use.
  ///
  /// Defaults to [MethodChannelSalamiUnlock].
  static SalamiUnlockPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SalamiUnlockPlatform] when
  /// they register themselves.
  static set instance(SalamiUnlockPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> requireUnlock(String? message) {
    throw UnimplementedError('requireUnlock() has not been implemented.');
  }

  Future<bool?> deviceCredentialsSetup() {
    throw UnimplementedError('deviceCredentialsSetup() has not been implemented.');
  }
}
