import 'package:flutter/material.dart';
import 'package:sample/helper/gradient_app_bar.dart';
import 'package:sample/services/word_list_service.dart';
import 'package:sample/widgets/shake_widget.dart';
import 'dart:math';

class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  late GlobalKey<ShakeWidgetState> shakeKey;
  final int maxAttempts = 6;
  final int wordLength = 5;
  final String secretWord = validWords.toList()[
      Random().nextInt(validWords.length)]; // <-- make this dynamic later
  bool gameOver = false;
  List<String> guesses = [];
  String currentGuess = '';
  Map<String, String> letterStatus = {}; // e.g., {'A': 'green', 'B': 'grey'}

  @override
  void initState() {
    super.initState();
    shakeKey = GlobalKey<ShakeWidgetState>();
  }

  void onKeyPressed(String letter) {
    if (currentGuess.length < wordLength) {
      setState(() {
        currentGuess += letter.toUpperCase();
      });
    }
  }

  void onBackspace() {
    if (currentGuess.isNotEmpty) {
      setState(() {
        currentGuess = currentGuess.substring(0, currentGuess.length - 1);
      });
    }
  }

  void onSubmit() {
    if (currentGuess.length != wordLength || gameOver) return;

    if (!validWords.contains(currentGuess.toUpperCase())) {
      shakeKey.currentState?.shake();
      print('Invalid word');
      return;
    }

    setState(() {
      guesses.add(currentGuess);
    });

    if (currentGuess.toUpperCase() == secretWord) {
      setState(() {
        gameOver = true;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('🎉 You guessed it!'),
            content: Text('The word was "$secretWord".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    } else if (guesses.length >= maxAttempts) {
      setState(() {
        gameOver = true;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Game Over 😞'),
            content: Text('The word was "$secretWord".'),
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

    updateLetterStatus(currentGuess);

    setState(() {
      currentGuess = '';
    });
  }

  List<Color> evaluateGuess(String guess) {
    final guessLetters = guess.split('');
    final secretLetters = secretWord.split('');
    final colors = List<Color>.filled(wordLength, Colors.white);
    final letterCounts = <String, int>{};

    // Count each letter in the secret word
    for (var letter in secretLetters) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }

    // First pass: check for correct positions (green)
    for (int i = 0; i < wordLength; i++) {
      if (guessLetters[i] == secretLetters[i]) {
        colors[i] = Colors.green;
        letterCounts[guessLetters[i]] = letterCounts[guessLetters[i]]! - 1;
      }
    }

    // Second pass: check for correct letters in wrong positions (yellow)
    for (int i = 0; i < wordLength; i++) {
      if (colors[i] != Colors.white) continue; // already marked green

      final letter = guessLetters[i];
      if (letterCounts.containsKey(letter) && letterCounts[letter]! > 0) {
        colors[i] = Colors.yellow[700]!;
        letterCounts[letter] = letterCounts[letter]! - 1;
      }
    }

    return colors;
  }

  void updateLetterStatus(String guess) {
    final tempSecret = secretWord.split('');
    final guessLetters = guess.split('');

    // Step 1: Mark green letters first
    for (int i = 0; i < wordLength; i++) {
      final gLetter = guessLetters[i];
      if (gLetter == tempSecret[i]) {
        letterStatus[gLetter] = 'green';
        tempSecret[i] = ''; // Mark as matched
        guessLetters[i] = ''; // Prevent from reprocessing
      }
    }

    // Step 2: Mark yellow and grey
    for (int i = 0; i < wordLength; i++) {
      final gLetter = guessLetters[i];
      if (gLetter == '') continue;

      if (tempSecret.contains(gLetter)) {
        // Only upgrade to yellow if not already green
        if (letterStatus[gLetter] != 'green') {
          letterStatus[gLetter] = 'yellow';
        }
        tempSecret[tempSecret.indexOf(gLetter)] = ''; // mark as used
      } else {
        // Only downgrade to grey if not already yellow or green
        if (!letterStatus.containsKey(gLetter)) {
          letterStatus[gLetter] = 'grey';
        }
      }
    }
  }

  Widget buildGuessRow(String guess) {
    final colors = evaluateGuess(guess);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(wordLength, (index) {
        final letter = guess[index];
        final color = colors[index];

        return Container(
          margin: const EdgeInsets.all(4),
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
      }),
    );
  }

  Widget buildEmptyRow() {
    return ShakeWidget(
      key: shakeKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(wordLength, (index) {
          final letter = index < currentGuess.length ? currentGuess[index] : '';
          return Container(
            margin: const EdgeInsets.all(4),
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[700]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildKeyboard() {
    const keys = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    const double keySize = 30.0; // Fixed width and height for all keys

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Letter rows
        for (final row in keys)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.split('').map((letter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: SizedBox(
                    width: keySize,
                    height: keySize,
                    child: ElevatedButton(
                      onPressed: () => onKeyPressed(letter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: () {
                          final status = letterStatus[letter];
                          switch (status) {
                            case 'green':
                              return Colors.green;
                            case 'yellow':
                              return Colors.yellow[700];
                            case 'grey':
                              return Colors.grey[500];
                            default:
                              return Colors.white;
                          }
                        }(),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Bottom row: Backspace and Enter
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: keySize * 2,
                height: keySize,
                child: ElevatedButton(
                  onPressed: onBackspace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.backspace,
                      color: Colors.black, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: keySize * 2,
                height: keySize,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors
                              .green.shade800; // Darker green when pressed
                        }
                        return Colors.green; // Default green
                      },
                    ),
                    elevation: WidgetStateProperty.resolveWith<double>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return 0; // Flat when pressed
                        }
                        return 4; // Normal elevation
                      },
                    ),
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                  ),
                  child: const Text(
                    'Enter',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GradientAppBar(title: 'Wordle'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ...guesses.map(buildGuessRow),
          if (guesses.length < maxAttempts) buildEmptyRow(),
          const Spacer(),
          buildKeyboard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
