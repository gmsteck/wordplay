import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/provider/auth_provider.dart';
import 'package:sample/provider/game_list_provider.dart';
import 'package:sample/provider/user_provider.dart';
import 'package:sample/service/user_service.dart';
import 'package:sample/view/base_page.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  bool _isUpdating = false;
  late Future<String> _usernameFuture;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      _usernameFuture = _fetchUsername(user.id);
    }
  }

  Future<String> _fetchUsername(String userId) async {
    return ref
        .read(gameListControllerProvider(userId).notifier)
        .getUsername(userId);
  }

  void _refreshUsername(String userId) {
    setState(() {
      _usernameFuture = _fetchUsername(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(),
      );
    }

    return FutureBuilder<String>(
      future: _usernameFuture,
      builder: (context, snapshot) {
        final username = snapshot.connectionState == ConnectionState.done
            ? snapshot.data ?? 'Unknown'
            : 'Loading...';

        return Stack(
          children: [
            BasePage(
              title: 'User Info',
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundImage: NetworkImage(user.pictureUrl.toString()),
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
                          _editableUsernameRow(context, username, user.id),
                          _userEntry('Email', user.email),
                          _userEntry(
                              'Updated At', user.lastUpdated.toIso8601String()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isUpdating)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _editableUsernameRow(
      BuildContext context, String username, String userId) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(vertical: 2),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Name', style: TextStyle(color: Colors.black)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.edit,
                            color: Color.fromRGBO(255, 68, 221, 1)),
                        onPressed: _isUpdating
                            ? null
                            : () async {
                                final newName =
                                    await _showEditDialog(context, username);
                                if (newName != null &&
                                    newName.trim().isNotEmpty) {
                                  setState(() => _isUpdating = true);
                                  try {
                                    final userService =
                                        ref.read(userServiceProvider);
                                    await userService.updateUsername(
                                        userId, newName.trim());

                                    // Update game list cache
                                    ref
                                        .read(gameListControllerProvider(userId)
                                            .notifier)
                                        .updateUsernameCache(
                                            userId, newName.trim());

                                    // Refresh this page's username
                                    _refreshUsername(userId);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Username updated')),
                                    );
                                  } finally {
                                    setState(() => _isUpdating = false);
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isUpdating)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<String?> _showEditDialog(
      BuildContext context, String currentName) async {
    final TextEditingController controller =
        TextEditingController(text: currentName);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Username',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter new username',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 68, 221, 1),
                      ),
                      child: const Text('Save',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
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
              child: Text(value ?? '',
                  style: const TextStyle(color: Colors.black))),
        ],
      ),
    );
  }
}
