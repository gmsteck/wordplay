import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/wordle_state_model.dart';
import 'package:sample/widgets/shake_widget.dart';
import '../service/word_list_service.dart';

class WordleController extends StateNotifier<WordleState> {
  WordleController()
      : super(WordleState.initial(
          validWords.toList()[Random().nextInt(validWords.length)],
        ));

  void onKeyPressed(String letter) {
    if (state.currentGuess.length < state.wordLength) {
      state = state.copyWith(
        currentGuess: state.currentGuess + letter.toUpperCase(),
      );
    }
  }

  void onBackspace() {
    if (state.currentGuess.isNotEmpty) {
      state = state.copyWith(
        currentGuess:
            state.currentGuess.substring(0, state.currentGuess.length - 1),
      );
    }
  }

  void onSubmit(BuildContext context, GlobalKey<ShakeWidgetState> shakeKey) {
    if (state.currentGuess.length != state.wordLength || state.gameOver) return;

    if (!validWords.contains(state.currentGuess.toUpperCase())) {
      shakeKey.currentState?.shake();
      return;
    }

    final newGuesses = [...state.guesses, state.currentGuess];
    final isWin = state.currentGuess.toUpperCase() == state.secretWord;
    final isLose = newGuesses.length >= state.maxAttempts;

    updateLetterStatus(state.currentGuess);

    state = state.copyWith(
      guesses: newGuesses,
      gameOver: isWin || isLose,
      currentGuess: '',
    );

    if (isWin) {
      Future.delayed(const Duration(milliseconds: 100), () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('🎉 You guessed it!'),
            content: Text('The word was "${state.secretWord}".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    } else if (isLose) {
      Future.delayed(const Duration(milliseconds: 100), () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Game Over 😞'),
            content: Text('The word was "${state.secretWord}".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  void updateLetterStatus(String guess) {
    final tempSecret = state.secretWord.split('');
    final guessLetters = guess.split('');
    final updatedStatus = Map<String, String>.from(state.letterStatus);

    for (int i = 0; i < state.wordLength; i++) {
      final gLetter = guessLetters[i];
      if (gLetter == tempSecret[i]) {
        updatedStatus[gLetter] = 'green';
        tempSecret[i] = '';
        guessLetters[i] = '';
      }
    }

    for (int i = 0; i < state.wordLength; i++) {
      final gLetter = guessLetters[i];
      if (gLetter.isEmpty) continue;

      if (tempSecret.contains(gLetter)) {
        if (updatedStatus[gLetter] != 'green') {
          updatedStatus[gLetter] = 'yellow';
        }
        tempSecret[tempSecret.indexOf(gLetter)] = '';
      } else {
        if (!updatedStatus.containsKey(gLetter)) {
          updatedStatus[gLetter] = 'grey';
        }
      }
    }

    state = state.copyWith(letterStatus: updatedStatus);
  }

  List<Color> evaluateGuess(String guess) {
    final guessLetters = guess.split('');
    final secretLetters = state.secretWord.split('');
    final colors = List<Color>.filled(state.wordLength, Colors.white);
    final letterCounts = <String, int>{};

    for (var letter in secretLetters) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }

    for (int i = 0; i < state.wordLength; i++) {
      if (guessLetters[i] == secretLetters[i]) {
        colors[i] = Colors.green;
        letterCounts[guessLetters[i]] = letterCounts[guessLetters[i]]! - 1;
      }
    }

    for (int i = 0; i < state.wordLength; i++) {
      if (colors[i] != Colors.white) continue;

      final letter = guessLetters[i];
      if (letterCounts.containsKey(letter) && letterCounts[letter]! > 0) {
        colors[i] = Colors.yellow[700]!;
        letterCounts[letter] = letterCounts[letter]! - 1;
      }
    }

    return colors;
  }
}

final wordleControllerProvider =
    StateNotifierProvider<WordleController, WordleState>(
        (ref) => WordleController());
