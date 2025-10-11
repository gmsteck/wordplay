import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime lastUpdated;
  final DateTime createdAt;
  Uri? pictureUrl;

  UserModel(
      {required this.id,
      required this.name,
      required this.email,
      required this.lastUpdated,
      required this.createdAt,
      this.pictureUrl});

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
