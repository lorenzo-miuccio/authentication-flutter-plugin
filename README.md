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

  SalamiUnlock.requireUnlock(context, message: 'Please authenticate to unlock', onResult: onResult);
  
  // ...

  //Authentication callback example
  void onResult(LocalAuthResult authResult) {
    switch (authResult) {
      case LocalAuthResult.success:
        //the user managed to authenticate
        //...
        break;

      case LocalAuthResult.failure:
        //the user canceled the authentication process or failed to authenticate
        //...
        break;

      case LocalAuthResult.TBD:
        //no biometric or device credentials are enrolled.
        //...
        break;
      default:
        //other errors occurred
        //...
    }
  }
```

### Setup Credentials (only for Android)

If there is no device or biometric credentials already set up by the user, 
you can call the method `deviceCredentialsSetup()` to redirect the user to the security page 
of Android settings. On iOS devices this method 

```dart
import 'package:salami_unlock/salami_unlock.dart';
// ···
  final bool userRedirected = await SalamiUnlock.deviceCredentialsSetup(); // true if the user was redirected to the settings page, otherwise false
  // ···
```

C
