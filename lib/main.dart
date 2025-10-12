import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/provider/word_list_provider.dart';
import 'service/word_list_service.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  final wordService = WordValidationService();
  await wordService.loadWordList();
  runApp(
    ProviderScope(
      overrides: [
        wordValidationServiceProvider.overrideWithValue(wordService),
      ],
      child: const App(),
    ),
  );
}
