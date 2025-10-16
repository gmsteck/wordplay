import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/user_model.dart';
import 'package:sample/service/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final friendsProvider =
    FutureProvider.family<List<UserModel>, String>((ref, userId) async {
  final userService = ref.read(userServiceProvider);
  return userService.getFriends(userId);
});
