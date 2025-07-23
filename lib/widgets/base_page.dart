// lib/widgets/base_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/provider/auth_provider.dart';
import '../common/theme.dart';
import '../common/gradient_app_bar.dart';

class BasePage extends ConsumerWidget {
  final String title;
  final Widget child;
  final bool showBottomNav;

  const BasePage({
    super.key,
    required this.title,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GradientAppBar(title: title),
      body: child,
      bottomNavigationBar: showBottomNav
          ? Container(
              decoration: const BoxDecoration(
                gradient: appLinearGradient,
              ),
              child: Row(
                children: [
                  _BottomNavIcon(
                    icon: Icons.list,
                    tooltip: 'Game List',
                    onPressed: () => _navigateIfNeeded(context, '/gameList'),
                  ),
                  _BottomNavIcon(
                    icon: Icons.gamepad,
                    tooltip: 'Wordle',
                    onPressed: () => Navigator.of(context).pushNamed('/wordle'),
                  ),
                  _BottomNavIcon(
                    icon: Icons.person,
                    tooltip: 'User Page',
                    onPressed: () => _navigateIfNeeded(context, '/user'),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () => authController.logout(context),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  void _navigateIfNeeded(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _BottomNavIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
      ),
    );
  }
}
