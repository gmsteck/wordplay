import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/common/gradient_app_bar.dart';
import 'package:sample/controller/wordle_controller.dart';
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
    if (currentGuess.length != 5) {
      shakeKey.currentState?.shake();
      return;
    }
    final controller = ref.read(wordleGameControllerProvider.notifier);
    await controller.submitGuess(widget.gameId, currentGuess);
    setState(() {
      currentGuess = '';
    });
  }

  // You can implement this based on your controller’s evaluateGuess logic
  List<Color> evaluateGuess(String guess, WordleGame game) {
    // Basic example - customize with your game logic
    final List<Color> colors = List.filled(guess.length, Colors.grey);
    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == game.word[i]) {
        colors[i] = Colors.green;
      } else if (game.word.contains(guess[i])) {
        colors[i] = Colors.yellow.shade700;
      }
    }
    return colors;
  }

  // Letter status for keyboard coloring
  String getLetterStatus(String letter, WordleGame game) {
    letter = letter.toLowerCase();
    if (game.word.contains(letter)) {
      if (game.guesses.any((g) =>
          g.contains(letter) && g[game.word.indexOf(letter)] == letter)) {
        return 'green';
      }
      return 'yellow';
    }
    if (game.guesses.any((g) => g.contains(letter))) {
      return 'grey';
    }
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

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in keys)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.split('').map((letter) {
                  final status = getLetterStatus(letter, game);
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
