import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../backend/services/auth_service.dart';
import '../widgets/bottom_nav.dart';
import 'landing_page.dart';

// The app's root screen. Follows the sign-in state so returning users skip the
// landing page, and logging out returns to it without any manual navigation.
class AuthGate extends StatefulWidget {
  final AuthService? authService;

  const AuthGate({super.key, this.authService});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _authStateChanges =
      (widget.authService ?? AuthService()).authStateChanges;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.hasData ? const BottomNav() : const LandingPage();
      },
    );
  }
}
