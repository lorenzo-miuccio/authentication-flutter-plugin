import 'package:flutter/material.dart';
import 'package:salami_unlock/salami_unlock.dart';

class RequestAuthEnrollDialog extends StatelessWidget {
  const RequestAuthEnrollDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Any device authentication system found.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Do you want to configure?",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => SalamiUnlock.deviceCredentialsSetup().then((res) {
                      if (res == false) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Go to settings to setup your device credentials')));
                      }
                      Navigator.of(context).pop();
                    }),
                    child: const Text("Ok"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
