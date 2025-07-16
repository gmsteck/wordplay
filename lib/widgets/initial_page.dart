import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'login.dart';

class InitialPage extends StatelessWidget {
  final Auth0 auth0;
  final CredentialsManager credentialsManager;

  const InitialPage({
    super.key,
    required this.auth0,
    required this.credentialsManager,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginPage(
            auth0: auth0,
            credentialsManager: credentialsManager,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 3000),
        ),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.white,
    );
  }
}
