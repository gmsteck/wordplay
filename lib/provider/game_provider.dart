import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/controller/wordle_controller.dart';
import 'package:sample/model/wordle_game_model.dart';
import 'package:sample/service/game_service.dart';

final gameServiceProvider =
    FutureProvider.family<GameModel, String>((ref, gameId) async {
  final gameService = ref.read(gameId); // your GameService singleton/provider
  return await gameService.fetchGame(gameId);
});
