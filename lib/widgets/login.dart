// views/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sample/provider/auth_provider.dart';
import '../common/theme.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Center(
                child: FittedBox(
                  child: Text(
                    'WordPlay',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [Colors.pink, Colors.orange],
                        ).createShader(
                          Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
                        ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 180,
                child: Lottie.asset(
                  'assets/animations/dice.json',
                  repeat: true,
                  animate: true,
                ),
              ),
              const Spacer(),
              authState.isLoggingIn
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: appLinearGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => authController.login(context),
                        child: const Text('Sign Up/Login'),
                      ),
                    ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
