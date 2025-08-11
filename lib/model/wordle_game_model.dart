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

  factory WordleGame.fromMap(Map<String, dynamic> map) {
    return WordleGame(
      gameId: map['gameId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      word: map['word'],
      guesses: List<String>.from(map['guesses'] ?? []),
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']['seconds'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
                  (map['createdAt']['seconds'] as int) * 1000)
              .toIso8601String()
          : map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']['seconds'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
                  (map['updatedAt']['seconds'] as int) * 1000)
              .toIso8601String()
          : map['updatedAt']),
    );
  }
}
