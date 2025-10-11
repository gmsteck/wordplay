import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/service/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());
