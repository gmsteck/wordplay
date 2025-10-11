// lib/model/wordle_game_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class WordleGame {
  final String gameId;
  final String senderId;
  final String receiverId;
  final String word;
  final List<String> guesses;
  final String status; // 'pending' | 'in_progress' | 'won' | 'lost'
  final DateTime createdAt;
  final DateTime updatedAt;

  WordleGame({
    required this.gameId,
    required this.senderId,
    required this.receiverId,
    required this.word,
    required this.guesses,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create a WordleGame from a Map
  factory WordleGame.fromMap(Map<String, dynamic> map) {
    return WordleGame(
      gameId: map['gameId'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      word: map['word'] as String,
      guesses: List<String>.from(map['guesses'] ?? []),
      status: map['status'] as String,
      createdAt: _parseFirebaseTimestamp(map['createdAt']),
      updatedAt: _parseFirebaseTimestamp(map['updatedAt']),
    );
  }

  /// Converts a WordleGame to a Map
  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'senderId': senderId,
      'receiverId': receiverId,
      'word': word,
      'guesses': guesses,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Copy with method to create a modified copy
  WordleGame copyWith({
    String? gameId,
    String? senderId,
    String? receiverId,
    String? word,
    List<String>? guesses,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WordleGame(
      gameId: gameId ?? this.gameId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      word: word ?? this.word,
      guesses: guesses ?? this.guesses,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to parse Firebase Timestamps safely
  static DateTime _parseFirebaseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is Map<String, dynamic>) {
      // fallback if it’s somehow a map
      final seconds = value['seconds'] as int? ?? 0;
      final nanoseconds = value['nanoseconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000));
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    } else {
      throw Exception('Cannot parse timestamp: $value');
    }
  }
}
