import 'package:flutter/material.dart';
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

  WordleGameController(
      StateNotifierProviderRef<WordleGameController, WordleGameState> ref)
      : _service = ref.read(wordleGameServiceProvider),
        super(WordleGameState());

  void clearGame() {
    state = WordleGameState();
  }

  Future<void> loadGame(String gameId) async {
    try {
      // Clear old game first
      state = WordleGameState(isLoading: true, game: null, error: null);

      final game = await _service.getGameState(gameId: gameId);
      state = state.copyWith(game: game, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load game: ${e.toString()}',
      );
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
      state = state.copyWith(game: state.game, isLoading: true);
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

  /// Returns a map of each letter to its highest status across all guesses.
  Map<String, String> computeLetterStatusMap(WordleGame game) {
    final Map<String, String> letterStatus = {};

    for (final guess in game.guesses) {
      for (int i = 0; i < guess.length; i++) {
        final letter = guess[i].toLowerCase();
        final wordLetter = game.word[i].toLowerCase();

        if (letter == wordLetter) {
          letterStatus[letter] = 'green'; // highest priority
        } else if (game.word.contains(letter)) {
          // Only upgrade if not already green
          if (letterStatus[letter] != 'green') {
            letterStatus[letter] = 'yellow';
          }
        } else {
          // Only upgrade if not already green/yellow
          if (letterStatus[letter] != 'green' &&
              letterStatus[letter] != 'yellow') {
            letterStatus[letter] = 'grey';
          }
        }
      }
    }

    return letterStatus;
  }

  String getLetterStatusFromMap(String letter, Map<String, String> statusMap) {
    return statusMap[letter.toLowerCase()] ?? 'none';
  }

  List<Color> evaluateGuess(String guess, WordleGame game) {
    final colors = List<Color>.filled(guess.length, Colors.grey);
    final wordChars = game.word.split('');
    final guessChars = guess.split('');

    // First pass: mark greens
    for (int i = 0; i < guessChars.length; i++) {
      if (i < wordChars.length && guessChars[i] == wordChars[i]) {
        colors[i] = Colors.green;
        wordChars[i] = ''; // remove matched letter
      }
    }

    // Second pass: mark yellows
    for (int i = 0; i < guessChars.length; i++) {
      if (colors[i] == Colors.grey && wordChars.contains(guessChars[i])) {
        colors[i] = Colors.yellow.shade700;
        wordChars[wordChars.indexOf(guessChars[i])] = ''; // remove used letter
      }
    }

    return colors;
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
  return WordleGameController(ref);
});
