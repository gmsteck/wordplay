import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/common/gradient_app_bar.dart';
import 'package:sample/controller/wordle_controller.dart';
import 'package:sample/provider/word_list_provider.dart';
import 'package:sample/view/game_result.dart';
import 'package:sample/view/shake_widget.dart';

class WordlePage extends ConsumerStatefulWidget {
  final String gameId;
  const WordlePage({super.key, required this.gameId});

  @override
  ConsumerState<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends ConsumerState<WordlePage> {
  final GlobalKey<ShakeWidgetState> shakeKey = GlobalKey<ShakeWidgetState>();
  String currentGuess = '';
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wordleGameControllerProvider.notifier).loadGame(widget.gameId);
    });
  }

  void onKeyPressed(String letter) {
    final game = ref.read(wordleGameControllerProvider).game;
    if (game == null || game.status == 'won' || game.status == 'lost')
      return; // disable input
    if (currentGuess.length >= 5) return;
    setState(() {
      currentGuess += letter.toLowerCase();
    });
  }

  void onBackspace() {
    final game = ref.read(wordleGameControllerProvider).game;
    if (game == null || game.status == 'won' || game.status == 'lost') return;
    if (currentGuess.isEmpty) return;
    setState(() {
      currentGuess = currentGuess.substring(0, currentGuess.length - 1);
    });
  }

  Future<void> onSubmitGuess() async {
    final state = ref.watch(wordleGameControllerProvider);
    final controller = ref.read(wordleGameControllerProvider.notifier);
    final validator = ref.read(wordValidationServiceProvider);

    final game = state.game;
    if (game == null || game.status == 'won' || game.status == 'lost')
      return; // disable input

    if (state.game?.status == 'pending') {
      await controller.acceptGame(widget.gameId);
    }
    if (currentGuess.length != 5 || !validator.isValidWord(currentGuess)) {
      shakeKey.currentState?.shake();
      return;
    }

    await controller.submitGuess(widget.gameId, currentGuess);
    setState(() {
      currentGuess = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordleGameControllerProvider);
    final game = state.game;

    if (game != null && _resultShown && (game.status == 'in_progress')) {
      _resultShown = false;
    }

    if (state.error != null) {
      return Scaffold(
        appBar: const GradientAppBar(title: 'Wordle'),
        body: Center(child: Text(state.error!)),
      );
    }

    if (state.isLoading) {
      // Show overlay spinner or loading screen
      return Scaffold(
        body: Positioned.fill(
          child: Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(255, 68, 221, 1),
              ),
            ),
          ),
        ),
      );
    }

    if (game == null) {
      return Scaffold(
        appBar: const GradientAppBar(title: 'Wordle'),
        body: const Center(child: Text('No game data')),
      );
    }

    if (game.status == 'won' || game.status == 'lost') {
      _resultShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), // smoother corners
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal:
                  32, // controls how wide it is (smaller padding = wider)
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500, // limit max width for large screens
              ),
              child: GameResultView(
                title: game.status == 'won' ? 'You Won!' : 'You Lost',
                word: game.word,
                guesses: game.guesses,
              ),
            ),
          ),
        );
      });
    }

    Widget buildGuessRow(String guess) {
      final colors = ref
          .read(wordleGameControllerProvider.notifier)
          .evaluateGuess(guess, game);
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

      final letterStatusMap = ref
          .read(wordleGameControllerProvider.notifier)
          .computeLetterStatusMap(game);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in keys)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.split('').map((letter) {
                  final status = ref
                      .read(wordleGameControllerProvider.notifier)
                      .getLetterStatusFromMap(letter, letterStatusMap);
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
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ...game.guesses.map(buildGuessRow),
              if (game.status == 'in_progress' && game.guesses.length < 6)
                buildEmptyRow(currentGuess),
              const Spacer(),
              Opacity(
                opacity: game.status == 'in_progress' ? 1.0 : 0.3,
                child: IgnorePointer(
                  ignoring: game.status != 'in_progress',
                  child: buildKeyboard(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          if (state.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromRGBO(255, 68, 221, 1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
