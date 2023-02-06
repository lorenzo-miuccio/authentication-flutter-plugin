# salami_unlock

This Flutter plugin provides facility to perform local authentication of
the user.

On supported devices, this includes authentication with biometrics such as
fingerprint or facial recognition.

## Usage


### Request authentication

The `require()` method uses biometric authentication or pin/pattern/passcode if currently set up.
You can provide a message to be displayed on the authentication dialog and a callback triggered
when the authentication result is received.

```dart

import 'package:salami_unlock/salami_unlock.dart';
// ...

  SalamiUnlock.require(context, message: 'Please authenticate to unlock', onResult: onResult);
  
  // ...

  //Authentication callback example
  void onResult(LocalAuthResult authResult) {
    switch (authResult) {
      case LocalAuthResult.success:
        //insert code to be executed if the user managed to authenticate
        //...
        break;

      case LocalAuthResult.failure:
        //insert code to be executed if the user cancels the authentication process or fail to authenticate
        //...
        break;

      case LocalAuthResult.TBD:
        //insert code to be executed if no biometric or device credential is enrolled.
        //...
        break;
      default:
        //insert code to be executed if other errors occurred
        //...
    }
  }
```

### Device Capabilities

To check whether there is local authentication available on this device or not,
call `canCheckBiometrics` (if you need biometrics support) and/or
`isDeviceSupported()` (if you just need some device-level authentication):

<?code-excerpt "readme_excerpts.dart (CanCheck)"?>
```dart
import 'package:local_auth/local_auth.dart';
// ···
  final LocalAuthentication auth = LocalAuthentication();
  // ···
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
```

Currently the following biometric types are implemented:

- BiometricType.face
- BiometricType.fingerprint
- BiometricType.weak
- BiometricType.strong

### Enrolled Biometrics

`canCheckBiometrics` only indicates whether hardware support is available, not
whether the device has any biometrics enrolled. To get a list of enrolled
biometrics, call `getAvailableBiometrics()`.

The types are device-specific and platform-specific, and other types may be
added in the future, so when possible you should not rely on specific biometric
types and only check that some biometric is enrolled:

<?code-excerpt "readme_excerpts.dart (Enrolled)"?>
```dart
final List<BiometricType> availableBiometrics =
    await auth.getAvailableBiometrics();

if (availableBiometrics.isNotEmpty) {
  // Some biometrics are enrolled.
}

if (availableBiometrics.contains(BiometricType.strong) ||
    availableBiometrics.contains(BiometricType.face)) {
  // Specific types of biometrics are available.
  // Use checks like this with caution!
}
```

### Options

The `authenticate()` method uses biometric authentication when possible, but
also allows fallback to pin, pattern, or passcode.

<?code-excerpt "readme_excerpts.dart (AuthAny)"?>
```dart
try {
  final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to show account balance');
  // ···
} on PlatformException {
  // ...
}
```

To require biometric authentication, pass `AuthenticationOptions` with
`biometricOnly` set to `true`.

<?code-excerpt "readme_excerpts.dart (AuthBioOnly)"?>
```dart
final bool didAuthenticate = await auth.authenticate(
    localizedReason: 'Please authenticate to show account balance',
    options: const AuthenticationOptions(biometricOnly: true));
```

*Note*: `biometricOnly` is not supported on Windows since the Windows implementation's underlying API (Windows Hello) doesn't support selecting the authentication method.

#### Dialogs

The plugin provides default dialogs for the following cases:

1. Passcode/PIN/Pattern Not Set: The user has not yet configured a passcode on
   iOS or PIN/pattern on Android.
2. Biometrics Not Enrolled: The user has not enrolled any biometrics on the
   device.

If a user does not have the necessary authentication enrolled when
`authenticate` is called, they will be given the option to enroll at that point,
or cancel authentication.

If you don't want to use the default dialogs, set the `useErrorDialogs` option
to `false` to have `authenticate` immediately return an error in those cases.

<?code-excerpt "readme_excerpts.dart (NoErrorDialogs)"?>
```dart
import 'package:local_auth/error_codes.dart' as auth_error;
// ···
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to show account balance',
          options: const AuthenticationOptions(useErrorDialogs: false));
      // ···
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.notEnrolled) {
        // ...
      } else {
        // ...
      }
    }
```

If you want to customize the messages in the dialogs, you can pass
`AuthMessages` for each platform you support. These are platform-specific, so
you will need to import the platform-specific implementation packages. For
instance, to customize Android and iOS:

<?code-excerpt "readme_excerpts.dart (CustomMessages)"?>
```dart
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
// ···
    final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Oops! Biometric authentication required!',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ]);
```

See the platform-specific classes for details about what can be customized on
each platform.

### Exceptions

`authenticate` throws `PlatformException`s in many error cases. See
`error_codes.dart` for known error codes that you may want to have specific
handling for. For example:

<?code-excerpt "readme_excerpts.dart (ErrorHandling)"?>
```dart
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
// ···
  final LocalAuthentication auth = LocalAuthentication();
  // ···
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to show account balance',
          options: const AuthenticationOptions(useErrorDialogs: false));
      // ···
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        // ...
      } else {
        // ...
      }
    }
```
