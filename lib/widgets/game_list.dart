// lib/game_list.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample/widgets/base_page.dart';
import 'package:sample/widgets/wordle.dart';

class GameListPage extends StatelessWidget {
  const GameListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const BasePage(
        title: 'Game List',
        child: Center(child: Text('Not logged in')),
      );
    }

    final gamesRef = FirebaseFirestore.instance
        .collection('games')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    return BasePage(
      title: 'Game List',
      child: StreamBuilder<QuerySnapshot>(
        stream: gamesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No games found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final gameId = doc['gameId'] as String;
              final senderId = doc['senderId'] as String;
              final createdAt = (doc['createdAt'] as Timestamp).toDate();

              return GestureDetector(
                onTap: () {
                  // Navigate to WordlePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordlePage(gameId: gameId),
                    ),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Game from $senderId'),
                    subtitle: Text('Game ID: $gameId\nCreated: $createdAt'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
