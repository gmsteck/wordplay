import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/user_model.dart';
import 'package:sample/provider/auth_provider.dart';
import 'package:sample/provider/user_provider.dart';
import 'package:sample/view/base_page.dart';

class FriendsPage extends ConsumerWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('No user logged in')),
      );
    }

    final friendsAsync = ref.watch(friendsProvider(user.id));

    return BasePage(
      title: 'Friends',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(friendsProvider(user.id));
        },
        child: friendsAsync.when(
          data: (friends) {
            if (friends.isEmpty) {
              return const Center(
                child: Text('No friends added yet',
                    style: TextStyle(color: Colors.black54)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return _friendCard(friend);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.black),
          ),
          error: (e, _) => Center(
            child: Text('Failed to load friends: $e',
                style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  Widget _friendCard(UserModel friend) {
    return Card(
      elevation: 3,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: friend.pictureUrl != null
              ? NetworkImage(friend.pictureUrl.toString())
              : null,
          backgroundColor: Colors.grey.shade200,
          child: friend.pictureUrl == null
              ? const Icon(Icons.person, color: Colors.black54)
              : null,
        ),
        title: Text(
          friend.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          friend.email,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
