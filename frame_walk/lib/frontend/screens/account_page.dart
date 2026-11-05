import 'package:flutter/material.dart';

import '../../backend/services/auth_service.dart';

class AccountPage extends StatelessWidget {
  final AuthService? authService;

  const AccountPage({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Account goes here.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => (authService ?? AuthService()).logOut(),
              child: const Text('Log Out', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
