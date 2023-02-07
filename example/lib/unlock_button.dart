import 'package:flutter/material.dart';
import 'package:salami_unlock/salami_unlock.dart';
import 'package:salami_unlock_example/request_auth_enroll_dialog.dart';
import 'package:salami_unlock_example/salami_page.dart';

class UnlockButton extends StatelessWidget {
  const UnlockButton({Key? key}) : super(key: key);

  //Authentication callback example
  void _authCallback(BuildContext context, LocalAuthResult authResult) {
    switch (authResult) {
      case LocalAuthResult.success:
        //Code executed if the user manages to authenticate
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SalamiPage()));
        break;

      case LocalAuthResult.failure:
        //Code executed if the user cancels the authentication process or fail to authenticate
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication failed')));
        break;

      case LocalAuthResult.TBD:
        //Code executed if no biometric or device credential is enrolled.
        showDialog(context: context, builder: (ctx) => const RequestAuthEnrollDialog()).then((value) => value);
        break;
      default:
        //Code executed if others errors occurred.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${authResult.name}')));
    }
  }

  void _requireAuth(BuildContext context) => SalamiUnlock.requireUnlock(
        context,
        message: 'Unlock to get a present',
        onResult: (authResult) => _authCallback(context, authResult),
      );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _requireAuth(context), child: const Text('unlock'));
  }
}
