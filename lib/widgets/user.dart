import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/provider/auth_provider.dart';
import 'base_page.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    // Trigger navigation after the build is done if user is null
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });

      return const Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(),
      );
    }

    return BasePage(
      title: 'User Info',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: CircleAvatar(
                radius: 56,
                backgroundImage: NetworkImage(user.pictureUrl.toString()),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _userEntry('ID', user.id),
                  _userEntry('Name', user.name),
                  _userEntry('Email', user.email),
                  _userEntry('Email Verified', user.emailVerified.toString()),
                  _userEntry('Updated At', user.lastUpdated.toIso8601String()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userEntry(String label, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black)),
          Flexible(
            child:
                Text(value ?? '', style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
