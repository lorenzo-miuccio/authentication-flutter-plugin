import 'package:flutter/material.dart';
import 'package:salami_unlock/salami_unlock.dart';
import 'package:salami_unlock_example/salami_page.dart';

class UnlockButton extends StatelessWidget {
  const UnlockButton({Key? key}) : super(key: key);

  void _authCallback(BuildContext context, bool authResult) {
    authResult
        ? Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SalamiPage()))
        : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication failed')));
  }

  Future<void> _requireAuth(BuildContext context) => SalamiUnlock.require(
      message: 'Unlock to get a present', onResult: (authResult) => _authCallback(context, authResult));

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _requireAuth(context), child: const Text('unlock'));
  }
}
