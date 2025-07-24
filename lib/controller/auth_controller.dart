// controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/auth_state.dart';
import 'package:sample/provider/navigation_provider.dart';
import '../service/auth_service.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthService authService;
  bool isLoggingIn = false;

  AuthController(this.authService) : super(const AuthState());

  Future<void> login(WidgetRef ref) async {
    try {
      state = state.copyWith(isLoggingIn: true);
      final user = await authService.login();
      state = state.copyWith(user: user, isLoggingIn: false);
      final nav = ref.read(navigationServiceProvider);
      nav.pushReplacementNamed('/game_list');
    } catch (e) {
      debugPrint('Login failed: $e');
      state = state.copyWith(isLoggingIn: false);
    } finally {
      isLoggingIn = false;
    }
  }

  Future<void> logout(WidgetRef ref) async {
    try {
      await authService.logout();
      final nav = ref.read(navigationServiceProvider);
      nav.pushReplacementNamed('/login');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
