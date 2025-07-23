// provider/auth_providers.dart
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../controller/auth_controller.dart';
import '../service/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final auth0 =
      Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
  final credentialsManager = auth0.credentialsManager;
  return AuthService(
      auth0: auth0,
      credentialsManager: credentialsManager); // optionally pass config
});

final authControllerProvider = Provider<AuthController>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});
