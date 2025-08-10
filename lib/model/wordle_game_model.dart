import 'package:cloud_firestore/cloud_firestore.dart';

enum GameStatus { pending, inProgress, won, lost }

class WordleGame {
  final String id;
  final String senderId;
  final String receiverId;
  final String word;
  final int currentGuess;
  final List<String> guesses;
  final GameStatus status;
  final Timestamp createdAt;

  WordleGame({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.word,
    required this.currentGuess,
    required this.guesses,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'word': word,
      'currentGuess': currentGuess,
      'guesses': guesses,
      'status': status.name,
      'createdAt': createdAt,
    };
  }

  factory WordleGame.fromMap(String id, Map<String, dynamic> map) {
    return WordleGame(
      id: id,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      word: map['word'],
      currentGuess: map['currentGuess'],
      guesses: List<String>.from(map['guesses']),
      status: GameStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: map['createdAt'],
    );
  }
}
