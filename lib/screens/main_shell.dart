// lib/screens/main_shell.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: NavigationBar(
              height: 72,
              backgroundColor: colorScheme.surface.withOpacity(0.9),
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => _onTap(context, index),
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_filled),
                  label: 'Главная',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Календарь',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome),
                  label: 'Ассистент',
                ),
                NavigationDestination(
                  icon: Icon(Icons.feed_outlined),
                  selectedIcon: Icon(Icons.view_timeline),
                  label: 'Лента',
                ),
                NavigationDestination(
                  icon: Icon(Icons.checklist_rtl),
                  selectedIcon: Icon(Icons.checklist),
                  label: 'Прогресс',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Профиль',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return switch (location) {
      '/' => 0,
      '/calendar' => 1,
      '/assistant' => 2,
      '/feed' => 3,
      '/progress' => 4,
      '/profile' => 5,
      _ => 0,
    };
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/assistant');
        break;
      case 3:
        context.go('/feed');
        break;
      case 4:
        context.go('/progress');
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }
}
