import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salami_unlock/salami_unlock_method_channel.dart';

void main() {
  MethodChannelSalamiUnlock platform = MethodChannelSalamiUnlock();
  const MethodChannel channel = MethodChannel('salami_unlock');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
