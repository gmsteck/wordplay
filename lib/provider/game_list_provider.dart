import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/controller/game_list_controller.dart';
import 'package:sample/model/wordle_game_model.dart';
import 'package:sample/provider/user_provider.dart';
import 'package:sample/service/game_service.dart';

final gameListControllerProvider = StateNotifierProvider.family<
    GameListController, AsyncValue<List<WordleGame>>, String>((ref, userId) {
  final gameService = WordleGameService();
  final userService = ref.read(userServiceProvider);
  return GameListController(gameService, userService, userId);
});
