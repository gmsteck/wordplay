import 'package:flutter/material.dart';

class WordleState {
  final int maxAttempts;
  final int wordLength;
  final String secretWord;
  final bool gameOver;
  final List<String> guesses;
  final String currentGuess;
  final Map<String, String> letterStatus;

  WordleState({
    required this.maxAttempts,
    required this.wordLength,
    required this.secretWord,
    required this.gameOver,
    required this.guesses,
    required this.currentGuess,
    required this.letterStatus,
  });

  WordleState copyWith({
    int? maxAttempts,
    int? wordLength,
    String? secretWord,
    bool? gameOver,
    List<String>? guesses,
    String? currentGuess,
    Map<String, String>? letterStatus,
  }) {
    return WordleState(
      maxAttempts: maxAttempts ?? this.maxAttempts,
      wordLength: wordLength ?? this.wordLength,
      secretWord: secretWord ?? this.secretWord,
      gameOver: gameOver ?? this.gameOver,
      guesses: guesses ?? this.guesses,
      currentGuess: currentGuess ?? this.currentGuess,
      letterStatus: letterStatus ?? this.letterStatus,
    );
  }

  factory WordleState.initial(String secretWord) {
    return WordleState(
      maxAttempts: 6,
      wordLength: 5,
      secretWord: secretWord,
      gameOver: false,
      guesses: [],
      currentGuess: '',
      letterStatus: {},
    );
  }
}
