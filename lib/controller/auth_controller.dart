// controllers/auth_controller.dart
import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../widgets/game_list.dart'; // or your actual GameListPage import

class AuthController extends ChangeNotifier {
  final AuthService authService;
  bool isLoggingIn = false;

  AuthController(this.authService);

  Future<void> login(BuildContext context) async {
    isLoggingIn = true;
    notifyListeners();

    try {
      final user = await authService.login();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GameListPage(
              auth0: authService.auth0,
              credentialsManager: authService.credentialsManager,
              authController: this,
              user: user!,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Login failed: $e');
    } finally {
      isLoggingIn = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await authService.logout();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
