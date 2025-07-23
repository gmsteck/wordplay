import 'package:flutter/services.dart' show rootBundle;

late Set<String> validWords;

Future<void> loadWordList() async {
  final wordString = await rootBundle.loadString('assets/words.txt');
  validWords =
      wordString.split('\n').map((word) => word.trim().toUpperCase()).toSet();
}
