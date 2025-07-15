// lib/game_list.dart
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'base_page.dart';

class GameListPage extends StatelessWidget {
  final Auth0 auth0;
  final CredentialsManager credentialsManager;
  final UserProfile user;

  const GameListPage({
    super.key,
    required this.auth0,
    required this.credentialsManager,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      auth0: auth0,
      credentialsManager: credentialsManager,
      user: user,
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
