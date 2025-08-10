import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/controller/wordle_controller.dart';
import 'package:sample/model/wordle_state_model.dart';

final wordleControllerProvider =
    StateNotifierProvider<WordleController, WordleState>(
        (ref) => WordleController());
