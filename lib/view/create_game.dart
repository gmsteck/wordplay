import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/provider/auth_provider.dart';
import 'package:sample/provider/game_provider.dart';
import 'package:sample/provider/word_list_provider.dart';
import 'package:sample/view/base_page.dart';

class CreateGamePage extends ConsumerStatefulWidget {
  const CreateGamePage({super.key});

  @override
  ConsumerState<CreateGamePage> createState() => _GameListPageState();
}

class _GameListPageState extends ConsumerState<CreateGamePage> {
  bool _isCreatingGame = false;

  Future<void> _createTestGame() async {
    setState(() {
      _isCreatingGame = true;
    });

    try {
      final authState = ref.read(authControllerProvider);
      final user = authState.user;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Example: send a test game to yourself with word 'flutter'
      final wordService = ref.read(wordValidationServiceProvider);
      final testWord = wordService.getRandomWord();
      final gameService = ref.read(wordleGameServiceProvider);
      final gameId = await gameService.createGame(
        receiverId: user.id,
        word: testWord,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test game created! ID: $gameId')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating game: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingGame = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Game List',
      child: Center(
        child: _isCreatingGame
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _createTestGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(255, 68, 221, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Create Test Game',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
      ),
    );
  }
}
