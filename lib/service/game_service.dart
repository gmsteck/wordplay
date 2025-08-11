import 'package:cloud_functions/cloud_functions.dart';
import '../model/wordle_game_model.dart';

class WordleGameService {
  final FirebaseFunctions functions;

  WordleGameService({FirebaseFunctions? functions})
      : functions = functions ?? FirebaseFunctions.instance;

  Future<String> createGame({
    required String receiverId,
    required String word,
  }) async {
    final callable = functions.httpsCallable('createGame');
    final result = await callable.call({
      'receiverId': receiverId,
      'word': word,
    });
    return result.data['gameId'] as String;
  }

  Future<bool> acceptGame({required String gameId}) async {
    final callable = functions.httpsCallable('acceptGame');
    final result = await callable.call({'gameId': gameId});
    return result.data['success'] as bool;
  }

  Future<Map<String, dynamic>> submitGuess({
    required String gameId,
    required String guess,
  }) async {
    final callable = functions.httpsCallable('submitGuess');
    final result = await callable.call({
      'gameId': gameId,
      'guess': guess,
    });
    return {
      'status': result.data['status'] as String,
      'guesses': List<String>.from(result.data['guesses'] ?? []),
    };
  }

  Future<WordleGame> getGameState({required String gameId}) async {
    final callable = functions.httpsCallable('getGameState');
    final result = await callable.call({'gameId': gameId});
    return WordleGame.fromMap(Map<String, dynamic>.from(result.data));
  }
}
