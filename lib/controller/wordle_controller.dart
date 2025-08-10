import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/wordle_game_model.dart';
import 'package:sample/service/game_service.dart';

final gameServiceProvider = Provider((ref) => GameService());

final currentGameProvider =
    StreamProvider.family<WordleGame, String>((ref, gameId) {
  return ref.read(gameServiceProvider).watchGame(gameId);
});

class WordleController extends StateNotifier<WordleGame?> {
  WordleController(this.ref) : super(null);

  final Ref ref;

  void loadGame(String gameId) {
    ref.read(currentGameProvider(gameId).future).then((game) {
      state = game;
    });
  }

  Future<void> guess(String gameId, String guess) async {
    await ref.read(gameServiceProvider).updateGuess(gameId, guess);
  }

  final wordleControllerProvider =
      StateNotifierProvider.family<WordleController, WordleGame?, String>(
          (ref, gameId) {
    final game = ref.watch(gameServiceProvider(gameId)).valueOrNull;
    return WordleController(initialGame: game);
  });
}
