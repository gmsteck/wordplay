import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/wordle_game_model.dart';
import 'package:sample/service/game_service.dart';
import 'package:sample/service/user_service.dart';

class GameListController extends StateNotifier<AsyncValue<List<WordleGame>>> {
  final WordleGameService _gameService;
  final UserService _userService;
  final String userId;
  final Map<String, String> _usernameCache = {};

  GameListController(this._gameService, this._userService, this.userId)
      : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _gameService.getGamesForUser(userId).listen((games) async {
      // Optionally pre-fetch sender names
      for (final game in games) {
        await _getUsername(game.senderId);
      }
      state = AsyncValue.data(games);
    }, onError: (error, stack) {
      state = AsyncValue.error(error, stack);
    });
  }

  Future<String> _getUsername(String senderId) async {
    if (_usernameCache.containsKey(senderId)) {
      return _usernameCache[senderId]!;
    }
    try {
      final user = await _userService.getUserById(senderId);
      _usernameCache[senderId] = user.name;
      return user.name;
    } catch (_) {
      return 'Unknown';
    }
  }

  Future<String> getUsername(String senderId) => _getUsername(senderId);

  List<Color> evaluateGuessBoxes(String word, List<String> guesses) {
    final List<Color> boxes = List.filled(5, Colors.grey.shade100);
    for (int i = 0; i < guesses.length; i++) {
      final guess = guesses[i];
      for (int j = 0; j < guess.length && j < 5; j++) {
        final letter = guess[j].toLowerCase();
        if (word[j] == letter) {
          boxes[j] = Colors.green;
        }
      }
    }
    return boxes;
  }

  Future<void> refreshGames(String userId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final stream = _gameService.getGamesForUser(userId);
      final games = await stream.first; // <-- get the first snapshot
      return games;
    });
  }

  Future<void> acceptGame(String gameId) async {
    try {
      final success = await _gameService.acceptGame(gameId: gameId);
      if (success) {
        // Refresh the game list
        final games = await _gameService.getGamesForUser(userId).first;
        state = AsyncValue.data(games);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGame(String gameId) async {
    try {
      final success = await _gameService.deleteGame(gameId: gameId);
      if (success) {
        // Refresh the game list
        final games = await _gameService.getGamesForUser(userId).first;
        state = AsyncValue.data(games);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
