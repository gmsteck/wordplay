// model/auth_state.dart
import 'package:sample/model/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoggingIn;

  const AuthState({this.user, this.isLoggingIn = false});

  AuthState copyWith({
    UserModel? user,
    bool? isLoggingIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
    );
  }
}
