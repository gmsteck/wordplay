import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/wordle_game_model.dart';
import 'package:sample/provider/game_provider.dart';
import 'package:sample/service/game_service.dart'; // import the service and WordleGame model from previous code

// State class to hold loading/error/game data
class WordleGameState {
  final WordleGame? game;
  final bool isLoading;
  final String? error;

  WordleGameState({
    this.game,
    this.isLoading = false,
    this.error,
  });

  WordleGameState copyWith({
    WordleGame? game,
    bool? isLoading,
    String? error,
  }) {
    return WordleGameState(
      game: game ?? this.game,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WordleGameController extends StateNotifier<WordleGameState> {
  final WordleGameService _service;

  WordleGameController(this._service) : super(WordleGameState());

  Future<void> loadGame(String gameId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final game = await _service.getGameState(gameId: gameId);
      state = state.copyWith(game: game, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to load game: ${e.toString()}');
    }
  }

  Future<void> acceptGame(String gameId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _service.acceptGame(gameId: gameId);
      await loadGame(gameId); // refresh game state
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to accept game: ${e.toString()}');
    }
  }

  Future<void> submitGuess(String gameId, String guess) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final result = await _service.submitGuess(gameId: gameId, guess: guess);
      final updatedGame = state.game?.copyWith(
        guesses: List<String>.from(result['guesses']),
        status: result['status'],
      );
      state = state.copyWith(game: updatedGame, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to submit guess: ${e.toString()}');
    }
  }
}

// To enable copying WordleGame with updates
extension WordleGameCopyWith on WordleGame {
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
}

// Provider for the controller, depends on WordleGameService provider
final wordleGameControllerProvider =
    StateNotifierProvider<WordleGameController, WordleGameState>((ref) {
  final service = ref.read(wordleGameServiceProvider);
  return WordleGameController(service);
});
