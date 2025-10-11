import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample/model/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> getUserById(String uid) async {
    final doc = await _db.collection('user').doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    return UserModel.fromMap(doc.id, doc.data()!);
  }
}
