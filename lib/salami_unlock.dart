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
        if(context.mounted) onResult?.call(LocalAuthResult._getBy(nativeAuthResult));
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

  static LocalAuthResult _getBy(String nativeRensponse) {


    LocalAuthResult authResult;
    switch (nativeRensponse.toLowerCase()) {
      case "success":
        return LocalAuthResult.success;
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
