import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sample/common/theme.dart';
import 'package:sample/provider/game_list_provider.dart';
import 'package:sample/view/base_page.dart';
import 'package:sample/view/wordle.dart';

class GameListPage extends ConsumerWidget {
  const GameListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const BasePage(
        title: 'Game List',
        child: Center(child: Text('Not logged in')),
      );
    }

    final gameListAsync = ref.watch(gameListControllerProvider(userId));

    return BasePage(
      title: 'Game List',
      child: gameListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (games) => ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];

            return FutureBuilder<String>(
              future: ref
                  .read(gameListControllerProvider(userId).notifier)
                  .getUsername(game.senderId),
              builder: (context, snapshot) {
                final senderName = snapshot.data ?? 'Loading...';

                final formattedDate =
                    DateFormat('dd/MM/yy').format(game.createdAt);

                final boxes = ref
                    .read(gameListControllerProvider(userId).notifier)
                    .evaluateGuessBoxes(game.word, game.guesses);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordlePage(gameId: game.gameId),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      gradient: appLinearGradient,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: ListTile(
                      title: Text('Game from $senderName',
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Created: $formattedDate',
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Row(
                            children: boxes
                                .map((color) => Container(
                                      width: 16,
                                      height: 16,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                      trailing: Text('Guess ${game.guesses.length}/6',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
