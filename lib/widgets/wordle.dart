import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/common/gradient_app_bar.dart';
import 'package:sample/controller/wordle_controller.dart';
import 'package:sample/provider/word_list_provider.dart';
import 'package:sample/widgets/shake_widget.dart';
import '../model/wordle_game_model.dart'; // Your WordleGame model// The controller file

class WordlePage extends ConsumerStatefulWidget {
  final String gameId;
  const WordlePage({super.key, required this.gameId});

  @override
  ConsumerState<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends ConsumerState<WordlePage> {
  final GlobalKey<ShakeWidgetState> shakeKey = GlobalKey<ShakeWidgetState>();

  String currentGuess = '';

  @override
  void initState() {
    super.initState();
    // Load the game on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wordleGameControllerProvider.notifier).loadGame(widget.gameId);
    });
  }

  void onKeyPressed(String letter) {
    if (currentGuess.length >= 5) return;
    setState(() {
      currentGuess += letter.toLowerCase();
    });
  }

  void onBackspace() {
    if (currentGuess.isEmpty) return;
    setState(() {
      currentGuess = currentGuess.substring(0, currentGuess.length - 1);
    });
  }

  Future<void> onSubmitGuess() async {
    final validator = ref.read(wordValidationServiceProvider);
    if (currentGuess.length != 5 || !validator.isValidWord(currentGuess)) {
      shakeKey.currentState?.shake();
      return;
    }
    final controller = ref.read(wordleGameControllerProvider.notifier);
    final state = ref.watch(wordleGameControllerProvider);
    if (state.game?.status == 'pending') {
      await controller.acceptGame(widget.gameId);
    }
    await controller.submitGuess(widget.gameId, currentGuess);
    setState(() {
      currentGuess = '';
    });
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

  String getLetterStatus(String letter, WordleGame game) {
    letter = letter.toLowerCase();

    bool isGreen = false;
    bool isYellow = false;
    bool isGrey = false;

    for (final guess in game.guesses) {
      for (int i = 0; i < guess.length; i++) {
        final gLetter = guess[i].toLowerCase();
        if (gLetter != letter) continue;

        if (letter == game.word[i].toLowerCase()) {
          isGreen = true;
        } else if (game.word.contains(letter)) {
          isYellow = true;
        } else {
          isGrey = true;
        }
      }
    }

    if (isGreen) return 'green';
    if (isYellow) return 'yellow';
    if (isGrey) return 'grey';
    return 'none';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordleGameControllerProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: const GradientAppBar(title: 'Wordle'),
        body: Center(child: Text(state.error!)),
      );
    }

    final game = state.game;
    if (game == null) {
      return Scaffold(
        appBar: const GradientAppBar(title: 'Wordle'),
        body: const Center(child: Text('No game data')),
      );
    }

    Widget buildGuessRow(String guess) {
      final colors = evaluateGuess(guess, game);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(guess.length, (index) {
          final letter = guess[index].toUpperCase();
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

    Widget buildEmptyRow(String currentGuess) {
      return ShakeWidget(
        key: shakeKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(game.word.length, (index) {
            final letter = index < currentGuess.length
                ? currentGuess[index].toUpperCase()
                : '';
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
      const double keySize = 30.0;

      // Compute the status map once
      final letterStatusMap = computeLetterStatusMap(game);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in keys)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.split('').map((letter) {
                  final status =
                      getLetterStatusFromMap(letter, letterStatusMap);
                  Color bgColor;
                  switch (status) {
                    case 'green':
                      bgColor = Colors.green;
                      break;
                    case 'yellow':
                      bgColor = Colors.yellow.shade700;
                      break;
                    case 'grey':
                      bgColor = Colors.grey.shade500;
                      break;
                    default:
                      bgColor = Colors.white;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: keySize,
                      height: keySize,
                      child: ElevatedButton(
                        onPressed: () => onKeyPressed(letter),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgColor,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.zero,
                        ),
                        child:
                            Text(letter, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
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
                    onPressed: onSubmitGuess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Enter',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GradientAppBar(title: 'Wordle'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ...game.guesses.map(buildGuessRow),
          if (game.guesses.length < 6) // max attempts
            buildEmptyRow(currentGuess),
          const Spacer(),
          buildKeyboard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
