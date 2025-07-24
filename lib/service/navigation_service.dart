import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String? _currentRoute;

  String? get currentRoute => _currentRoute;

  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    _currentRoute = routeName;
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    _currentRoute = routeName;
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  void pop() {
    navigatorKey.currentState!.pop();
  }
}
