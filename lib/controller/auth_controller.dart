// controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/auth_state.dart';
import 'package:sample/provider/navigation_provider.dart';
import '../service/auth_service.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState());

  Future<void> login(String email, String password, WidgetRef ref) async {
    try {
      state = state.copyWith(isLoggingIn: true);
      final user = await _authService.login(email: email, password: password);
      state = state.copyWith(user: user, isLoggingIn: false);

      final nav = ref.read(navigationServiceProvider);
      nav.pushReplacementNamed('/game_list');
    } catch (e) {
      debugPrint('Login failed: $e');
      state = state.copyWith(isLoggingIn: false);
    }
  }

  Future<void> register(String email, String password, WidgetRef ref) async {
    try {
      state = state.copyWith(isLoggingIn: true);
      final user =
          await _authService.register(email: email, password: password);
      state = state.copyWith(user: user, isLoggingIn: false);

      final nav = ref.read(navigationServiceProvider);
      nav.pushReplacementNamed('/game_list');
    } catch (e) {
      debugPrint('Registration failed: $e');
      state = state.copyWith(isLoggingIn: false);
    }
  }

  Future<void> logout(WidgetRef ref) async {
    try {
      await _authService.logout();
      final nav = ref.read(navigationServiceProvider);
      nav.pushReplacementNamed('/login');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
