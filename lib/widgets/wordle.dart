import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/common/gradient_app_bar.dart';
import 'package:sample/widgets/shake_widget.dart';
import '../model/wordle_game_model.dart';
import '../provider/game_provider.dart'; // contains currentGameProvider & wordleControllerProvider

class WordlePage extends ConsumerWidget {
  final String gameId;
  const WordlePage({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(gameServiceProvider);
    final controller = ref.read(wordleControllerProvider.notifier);
    final shakeKey = GlobalKey<ShakeWidgetState>();

    Widget buildGuessRow(String guess) {
      final colors = controller.evaluateGuess(guess);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(guess.length, (index) {
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

    Widget buildEmptyRow(GameModel gameState, String currentGuess) {
      return ShakeWidget(
        key: shakeKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(gameState.word.length, (index) {
            final letter =
                index < currentGuess.length ? currentGuess[index] : '';
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

    Widget buildKeyboard(GameModel gameState, String currentGuess) {
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: keySize,
                      height: keySize,
                      child: ElevatedButton(
                        onPressed: () => controller.onKeyPressed(letter),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: () {
                            final status = controller.getLetterStatus(
                                letter, gameState.guesses, gameState.word);
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
                    onPressed: controller.onBackspace,
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
                    onPressed: () => controller.onSubmitGuess(
                      context: context,
                      shakeKey: shakeKey,
                      gameId: gameId,
                    ),
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
      body: gameAsync.when(
        data: (gameState) {
          final currentGuess =
              ref.watch(wordleControllerProvider)?.currentGuess ?? '';
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ...gameState.guesses.map(buildGuessRow),
              if (gameState.guesses.length < 6) // 6 max attempts
                buildEmptyRow(gameState, currentGuess),
              const Spacer(),
              buildKeyboard(gameState, currentGuess),
              const SizedBox(height: 16),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
    );
  }
}
