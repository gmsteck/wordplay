// views/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sample/provider/auth_provider.dart';
import '../common/theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true; // 🔥 Track mode (Login/Register)

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Title
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
                            const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
                          ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Animation
                SizedBox(
                  height: 180,
                  child: Lottie.asset(
                    'assets/animations/dice.json',
                    repeat: true,
                    animate: true,
                  ),
                ),

                const SizedBox(height: 40),

                // Email field
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            const Color.fromRGBO(255, 79, 64, 1), // opacity 1.0
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.black),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromRGBO(
                            255, 68, 221, 1), // opacity 1.0
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Loading indicator or buttons
                if (authState.isLoggingIn)
                  const CircularProgressIndicator()
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 🔹 Login button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _isLoginMode
                                ? appLinearGradient
                                : const LinearGradient(
                                    colors: [Colors.grey, Colors.grey],
                                  ),
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
                            onPressed: () {
                              if (!_isLoginMode) {
                                setState(() => _isLoginMode = true);
                              } else {
                                authController.login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  ref,
                                );
                              }
                            },
                            child: const Text('Login'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 🔹 Register button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: !_isLoginMode
                                ? appLinearGradient
                                : const LinearGradient(
                                    colors: [Colors.grey, Colors.grey],
                                  ),
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
                            onPressed: () {
                              if (_isLoginMode) {
                                setState(() => _isLoginMode = false);
                              } else {
                                authController.register(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  ref,
                                );
                              }
                            },
                            child: const Text('Register'),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
