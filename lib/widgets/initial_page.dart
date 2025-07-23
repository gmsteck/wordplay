import 'package:flutter/material.dart';
import 'package:sample/service/auth_service.dart';
import 'login.dart';

class InitialPage extends StatelessWidget {
  final AuthService authService;

  const InitialPage({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginPage(),
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
