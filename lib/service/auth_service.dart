// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/provider/user_provider.dart';
import '../model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref;
  AuthService(this.ref);

  Future<UserModel?> login(
      {required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;

      //get friends

      return UserModel(
        id: user.uid,
        pictureUrl: Uri(), // Firebase doesn't store picture URLs by default
        name: user.displayName ?? 'Unknown',
        email: user.email ?? 'no-email@example.com',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastUpdated: user.metadata.lastSignInTime ?? DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> register(
      {required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) return null;
      final tempName = user.email ?? 'Unknown';
      await ref
          .read(userServiceProvider)
          .createUserInFirebase(tempName, user.email!);

      return UserModel(
        id: user.uid,
        pictureUrl: Uri(),
        name: tempName,
        email: user.email ?? 'no-email@example.com',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastUpdated: user.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
