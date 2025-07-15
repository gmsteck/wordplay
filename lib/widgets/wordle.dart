import 'package:flutter/material.dart';
import 'package:sample/helper/gradient_app_bar.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  final int maxAttempts = 6;
  final int wordLength = 5;
  final String secretWord = 'CRANE'; // <-- make this dynamic later
  List<String> guesses = [];
  String currentGuess = '';

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
    if (currentGuess.length != wordLength) return;

    setState(() {
      guesses.add(currentGuess);
      currentGuess = '';
    });
  }

  Color getBoxColor(String letter, int position, String guess) {
    if (secretWord[position] == letter) {
      return Colors.green;
    } else if (secretWord.contains(letter)) {
      return Colors.yellow[700]!;
    } else {
      return Colors.white;
    }
  }

  Widget buildGuessRow(String guess) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(wordLength, (index) {
        final letter = guess[index];
        final color = getBoxColor(letter, index, guess);

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
    return Row(
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
                        backgroundColor: Colors.white,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Enter'),
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
