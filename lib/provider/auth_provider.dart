// provider/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/auth_state.dart';
import '../controller/auth_controller.dart';
import '../service/auth_service.dart';

// Provide AuthService (now using FirebaseAuth internally)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provide AuthController, which depends on AuthService
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});
