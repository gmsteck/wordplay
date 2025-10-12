import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

class WordValidationService {
  late final Set<String> _validWords;

  Future<void> loadWordList() async {
    final wordString = await rootBundle.loadString('assets/words.txt');
    _validWords =
        wordString.split('\n').map((word) => word.trim().toUpperCase()).toSet();
  }

  bool isValidWord(String word) {
    return _validWords.contains(word.toUpperCase());
  }

  String getRandomWord() {
    return _validWords.elementAt(Random().nextInt(_validWords.length - 1));
  }
}
