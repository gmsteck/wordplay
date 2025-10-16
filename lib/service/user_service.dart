import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> updateUsername(String userId, String newName) async {
    try {
      final callable = functions.httpsCallable('updateUsername');
      await callable.call({
        'userId': userId,
        'newName': newName,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Firebase function error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }

  final _db = FirebaseFirestore.instance;

  Future<List<UserModel>> getFriends(String userId) async {
    try {
      final callable = functions.httpsCallable('getFriendsByUserId');
      final result = await callable.call({'userId': userId});

      final List<dynamic> data = result.data as List<dynamic>;

      return data
          .map((friend) => UserModel.fromMap(
                friend['id'] as String,
                Map<String, dynamic>.from(friend),
              ))
          .toList();
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Firebase function error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch friends: $e');
    }
  }
}
