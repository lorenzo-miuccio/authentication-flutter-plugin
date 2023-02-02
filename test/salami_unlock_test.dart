import 'package:flutter_test/flutter_test.dart';
import 'package:salami_unlock/salami_unlock.dart';
import 'package:salami_unlock/salami_unlock_platform_interface.dart';
import 'package:salami_unlock/salami_unlock_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSalamiUnlockPlatform
    with MockPlatformInterfaceMixin
    implements SalamiUnlockPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SalamiUnlockPlatform initialPlatform = SalamiUnlockPlatform.instance;

  test('$MethodChannelSalamiUnlock is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSalamiUnlock>());
  });

  test('getPlatformVersion', () async {
    SalamiUnlock salamiUnlockPlugin = SalamiUnlock();
    MockSalamiUnlockPlatform fakePlatform = MockSalamiUnlockPlatform();
    SalamiUnlockPlatform.instance = fakePlatform;

    expect(await salamiUnlockPlugin.getPlatformVersion(), '42');
  });
}
