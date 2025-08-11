import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/service/game_service.dart';

// Riverpod provider for the WordleGameService
final wordleGameServiceProvider = Provider<WordleGameService>((ref) {
  return WordleGameService();
});
