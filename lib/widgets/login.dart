import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:sample/widgets/game_list.dart';
import '../helper/theme.dart';

class LoginPage extends StatefulWidget {
  final Auth0 auth0;
  final CredentialsManager credentialsManager;

  const LoginPage({
    super.key,
    required this.auth0,
    required this.credentialsManager,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    setState(() => _isLoggingIn = true);

    try {
      final credentials = await widget.auth0
          .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME']!)
          .login();

      await widget.credentialsManager.storeCredentials(credentials);

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GameListPage(
              auth0: widget.auth0,
              credentialsManager: widget.credentialsManager,
              user: credentials.user,
            ),
          ),
        );
      });
    } catch (e) {
      print('Login failed: $e');
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // Center(
              //   child: Text(
              //     'Word Games with Friends',
              //     style: TextStyle(
              //       fontSize: 48,
              //       fontWeight: FontWeight.bold,
              //       foreground: Paint()..shader = loginLinearGradient,
              //     ),
              //   ),
              // ),

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
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                    ),
                  ),
                ),
              ),

              // 👇 Add animation below the title
              SizedBox(
                height: 180,
                child: Lottie.asset(
                  'assets/animations/dice.json',
                  repeat: true,
                  animate: true,
                ),
              ),

              const Spacer(),

              _isLoggingIn
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
                        onPressed: _login,
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
