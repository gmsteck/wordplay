// lib/widgets/base_page.dart
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import '../helper/theme.dart';
import 'login.dart';
import 'wordle.dart';
import '../helper/gradient_app_bar.dart';

class BasePage extends StatefulWidget {
  final Auth0 auth0;
  final CredentialsManager credentialsManager;
  final UserProfile user;
  final String title;
  final Widget child;
  final bool showBottomNav;

  const BasePage({
    super.key,
    required this.auth0,
    required this.credentialsManager,
    required this.user,
    required this.title,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      // await widget.auth0
      //     .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME']!)
      //     .logout();
      await widget.credentialsManager.clearCredentials();
    } catch (e) {
      print('Logout error: $e');
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          auth0: widget.auth0,
          credentialsManager: widget.credentialsManager,
        ),
      ),
    );
  }

  void _goToGameListPage() {
    if (ModalRoute.of(context)?.settings.name != '/gameList') {
      Navigator.of(context).pushReplacementNamed(
        '/gameList',
        arguments: {
          'auth0': widget.auth0,
          'credentialsManager': widget.credentialsManager,
          'user': widget.user,
        },
      );
    }
  }

  void _goToUserPage() {
    if (ModalRoute.of(context)?.settings.name != '/user') {
      Navigator.of(context).pushReplacementNamed(
        '/user',
        arguments: {
          'auth0': widget.auth0,
          'credentialsManager': widget.credentialsManager,
          'user': widget.user,
        },
      );
    }
  }

  void _goToWordlePage() {
    if (ModalRoute.of(context)?.settings.name != '/wordle') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WordlePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GradientAppBar(
        title: widget.title,
      ),
      body: widget.child,
      bottomNavigationBar: widget.showBottomNav
          ? Container(
              decoration: const BoxDecoration(
                gradient: appLinearGradient,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: _goToGameListPage,
                      icon: const Icon(Icons.list, color: Colors.white),
                      tooltip: 'Game List',
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: _goToWordlePage,
                      icon: const Icon(Icons.gamepad, color: Colors.white),
                      tooltip: 'Wordle',
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: _goToUserPage,
                      icon: const Icon(Icons.person, color: Colors.white),
                      tooltip: 'User Page',
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: _isLoggingOut ? null : _logout,
                      icon: _isLoggingOut
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
