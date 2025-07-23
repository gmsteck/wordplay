// lib/game_list.dart
import 'package:flutter/material.dart';
import 'base_page.dart';

class GameListPage extends StatelessWidget {
  const GameListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Game List',
      child: const Center(
        child: Text(
          'Hello World',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
