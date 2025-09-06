// services/auth_service.dart
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/user_model.dart';

class AuthService {
  final Auth0 auth0;
  final CredentialsManager credentialsManager;

  AuthService({required this.auth0, required this.credentialsManager});

  Future<UserModel?> login() async {
    final credentials = await auth0
        .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME']!)
        .login();

    await credentialsManager.storeCredentials(credentials);

    final user = credentials.user;
    return UserModel(
        id: user.sub,
        pictureUrl: user.pictureUrl ?? Uri(),
        name: user.name ?? 'Unknown',
        email: user.email ?? 'no-email@example.com',
        emailVerified: user.isEmailVerified ?? false,
        lastUpdated: user.updatedAt ?? DateTime(0, 0, 0));
  }

  Future<void> logout() async {
    credentialsManager.clearCredentials();
    //await auth0.webAuthentication().logout();
  }
}
