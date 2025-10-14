import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime lastUpdated;
  final DateTime createdAt;
  final Uri? pictureUrl;
  final List<String> friends; // new field — list of user UIDs

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.lastUpdated,
    required this.createdAt,
    this.pictureUrl,
    this.friends = const [], // default to empty list
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime _parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is Map && value.containsKey('_seconds')) {
        return DateTime.fromMillisecondsSinceEpoch(value['_seconds'] * 1000);
      }
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: _parseDate(map['createdAt']),
      lastUpdated: _parseDate(map['lastUpdated']),
      pictureUrl:
          map['pictureUrl'] != null ? Uri.tryParse(map['pictureUrl']) : null,
      friends:
          (map['friends'] != null) ? List<String>.from(map['friends']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'pictureUrl': pictureUrl?.toString(),
      'friends': friends,
    };
  }
}
