import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/controller/wordle_controller.dart';
import 'package:sample/model/wordle_game_model.dart';
import 'package:sample/service/game_service.dart';

final gameServiceProvider = Provider<GameService>((ref) {
  return GameService();
});
