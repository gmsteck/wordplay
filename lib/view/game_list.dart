import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sample/common/theme.dart';
import 'package:sample/controller/wordle_controller.dart';
import 'package:sample/model/wordle_game_model.dart';
import 'package:sample/provider/game_list_provider.dart';
import 'package:sample/view/base_page.dart';
import 'package:sample/view/wordle.dart';

class GameListPage extends ConsumerStatefulWidget {
  const GameListPage({super.key});

  @override
  ConsumerState<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends ConsumerState<GameListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Keeps track of which games are currently loading (accept/delete)
  final Map<String, bool> _itemLoading = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        data: (games) {
          // Split games by state
          final activeGames = games
              .where((g) => g.status == 'pending' || g.status == 'in_progress')
              .toList();
          final pastGames = games
              .where((g) => g.status == 'won' || g.status == 'lost')
              .toList();

          return Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Past'),
                ],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color.fromRGBO(255, 68, 221, 1),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGameListView(activeGames, userId, showActions: true),
                    _buildGameListView(pastGames, userId, showActions: false),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameListView(
    List<WordleGame> games,
    String userId, {
    required bool showActions,
  }) {
    if (games.isEmpty) {
      return const Center(
          child: Text(
        'No games here',
        style: TextStyle(color: Colors.black),
      ));
    }

    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final isLoading = _itemLoading[game.gameId] ?? false;

        return FutureBuilder<String>(
          future: ref
              .read(gameListControllerProvider(userId).notifier)
              .getUsername(game.senderId),
          builder: (context, snapshot) {
            final senderName = snapshot.data ?? 'Loading...';
            final formattedDate = DateFormat('dd/MM/yy').format(game.createdAt);
            final boxes = ref
                .read(gameListControllerProvider(userId).notifier)
                .evaluateGuessBoxes(game.word, game.guesses);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                gradient: appLinearGradient,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Game from $senderName',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created: $formattedDate',
                            style: const TextStyle(color: Colors.white70),
                          ),
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
                      trailing: Text(
                        'Guess ${game.guesses.length}/6',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        if (isLoading) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProviderScope(
                              overrides: [
                                wordleGameControllerProvider.overrideWith(
                                  (ref) => WordleGameController(ref),
                                ),
                              ],
                              child: WordlePage(
                                key: ValueKey(game.gameId),
                                gameId: game.gameId,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (showActions && game.status == 'pending')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton(
                              icon: Icons.check,
                              color: const Color.fromRGBO(255, 79, 64, 1),
                              loading: isLoading,
                              onPressed: () async {
                                setState(
                                    () => _itemLoading[game.gameId] = true);
                                try {
                                  await ref
                                      .read(gameListControllerProvider(userId)
                                          .notifier)
                                      .acceptGame(game.gameId);
                                } finally {
                                  setState(
                                      () => _itemLoading[game.gameId] = false);
                                }
                              },
                            ),
                            const SizedBox(width: 16),
                            _buildActionButton(
                              icon: Icons.cancel,
                              color: const Color.fromRGBO(255, 68, 221, 1),
                              loading: isLoading,
                              onPressed: () async {
                                setState(
                                    () => _itemLoading[game.gameId] = true);
                                try {
                                  await ref
                                      .read(gameListControllerProvider(userId)
                                          .notifier)
                                      .deleteGame(game.gameId);
                                } finally {
                                  setState(
                                      () => _itemLoading[game.gameId] = false);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.black),
            )
          : Icon(icon, color: color),
    );
  }
}
