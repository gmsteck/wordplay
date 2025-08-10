import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/wordle_game_model.dart';

class GameService {
  final _db = FirebaseFirestore.instance;

  Future<String> createGame({
    required String senderId,
    required String receiverId,
    required String word,
  }) async {
    final gameRef = await _db.collection('games').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'word': word,
      'currentGuess': 0,
      'guesses': [],
      'status': GameStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return gameRef.id;
  }

  Future<void> updateGuess(
    String gameId,
    String guess,
  ) async {
    final gameRef = _db.collection('games').doc(gameId);
    final snapshot = await gameRef.get();

    if (!snapshot.exists) throw Exception('Game not found');

    final data = snapshot.data()!;
    final guesses = List<String>.from(data['guesses']);
    guesses.add(guess);

    await gameRef.update({
      'guesses': guesses,
      'currentGuess': guesses.length,
      'status': guesses.last == data['word']
          ? GameStatus.completed.name
          : guesses.length >= 6
              ? GameStatus.completed.name
              : GameStatus.inProgress.name,
    });
  }

  Stream<WordleGame> watchGame(String gameId) {
    return _db.collection('games').doc(gameId).snapshots().map((doc) {
      return WordleGame.fromMap(doc.id, doc.data()!);
    });
  }
}
