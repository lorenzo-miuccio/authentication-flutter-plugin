import 'package:flutter/material.dart';
import 'package:salami_unlock/salami_unlock.dart';
import 'package:salami_unlock_example/none_auth_dialog.dart';
import 'package:salami_unlock_example/salami_page.dart';

class UnlockButton extends StatelessWidget {
  const UnlockButton({Key? key}) : super(key: key);

  void _authCallback(BuildContext context, LocalAuthResult authResult) {
    switch (authResult) {
      case LocalAuthResult.success:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SalamiPage()));
        break;
      case LocalAuthResult.failure:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication failed')));
        break;
      case LocalAuthResult.TBD:
        showDialog(context: context, builder: (ctx) => const NoneAuthDialog())
            .then((value) => value);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${authResult.name}')));
    }
  }

  Future<void> _requireAuth(BuildContext context) => SalamiUnlock.require(
      message: 'Unlock to get a present', onResult: (authResult) => _authCallback(context, authResult));

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _requireAuth(context), child: const Text('unlock'));
  }
}
