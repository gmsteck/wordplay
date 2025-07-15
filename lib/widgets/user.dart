import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'base_page.dart';

class UserPage extends StatefulWidget {
  final Auth0 auth0;
  final CredentialsManager credentialsManager;
  final UserProfile user;

  const UserPage({
    super.key,
    required this.auth0,
    required this.credentialsManager,
    required this.user,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return BasePage(
      auth0: widget.auth0,
      credentialsManager: widget.credentialsManager,
      user: user,
      title: 'User Info',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (user.pictureUrl != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: CircleAvatar(
                  radius: 56,
                  backgroundImage: NetworkImage(user.pictureUrl!.toString()),
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
                  _userEntry('ID', user.sub),
                  _userEntry('Name', user.name),
                  _userEntry('Email', user.email),
                  _userEntry('Email Verified', user.isEmailVerified.toString()),
                  _userEntry('Updated At', user.updatedAt?.toIso8601String()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
