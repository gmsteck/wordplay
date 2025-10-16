import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/provider/navigation_provider.dart';
import 'package:sample/view/create_game.dart';
import 'package:sample/view/friends.dart';
import 'package:sample/view/initial_page.dart';
import 'package:sample/view/wordle.dart';
import 'view/game_list.dart';
import 'view/login.dart';
import 'view/user.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: ref.watch(navigationServiceProvider).navigatorKey,
      theme: ThemeData.dark(), // or your custom theme
      home: InitialPage(),
      routes: {
        '/create_game': (context) {
          return CreateGamePage();
        },
        '/friends': (context) {
          return FriendsPage();
        },
        '/loading': (context) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        '/login': (context) => LoginPage(),
        '/game_list': (context) {
          return GameListPage();
        },
        '/user': (context) {
          return UserPage();
        },
        '/wordle': (context) => const WordlePage(
              gameId: '1',
            ),
      },
    );
  }
}
