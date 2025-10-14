import 'package:sample/model/user_model.dart';
import 'package:cloud_functions/cloud_functions.dart';

class UserService {
  final FirebaseFunctions functions;
  UserService({FirebaseFunctions? functions})
      : functions = functions ?? FirebaseFunctions.instance;

  Future<UserModel> getUserById(String uid) async {
    try {
      final callable = functions.httpsCallable('getUserById');
      final result = await callable.call({'userId': uid});

      final data = Map<String, dynamic>.from(result.data);

      return UserModel.fromMap(data['id'], data);
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Firebase function error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<void> createUserInFirebase(String name, String email,
      {String? pictureUrl}) async {
    final callable = functions.httpsCallable('createUser');
    await callable.call({
      'name': name,
      'email': email,
      'pictureUrl': pictureUrl,
    });
  }
}
