import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'salami_unlock_method_channel.dart';
part 'salami_unlock_platform_interface.dart';

class SalamiUnlock {
  SalamiUnlock._();

  static void require(BuildContext context, {String? message, void Function(LocalAuthResult)? onResult}) =>

      SalamiUnlockPlatform.instance
      .requireUnlock(message)
      .then((nativeAuthResult) {
        if(context.mounted) onResult?.call(LocalAuthResult._getByNativeResponse(nativeAuthResult));
      });

  static Future<bool> deviceCredentialsSetup() => SalamiUnlockPlatform.instance.deviceCredentialsSetup();
}

enum LocalAuthResult {
  success,
  failure,
  TBD,
  unsupported,
  updateNeeded,
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
