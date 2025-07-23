// controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/auth_state.dart';
import '../service/auth_service.dart';
import '../widgets/game_list.dart'; // or your actual GameListPage import

class AuthController extends StateNotifier<AuthState> {
  final AuthService authService;
  bool isLoggingIn = false;

  AuthController(this.authService) : super(const AuthState());

  Future<void> login(BuildContext context) async {
    try {
      state = state.copyWith(isLoggingIn: true);
      final user = await authService.login();
      state = state.copyWith(user: user, isLoggingIn: false);
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GameListPage(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Login failed: $e');
      state = state.copyWith(isLoggingIn: false);
    } finally {
      isLoggingIn = false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await authService.logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
