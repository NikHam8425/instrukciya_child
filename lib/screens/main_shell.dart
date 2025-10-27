import 'package:flutter/material.dart';

import 'sections_screen.dart';
import 'assistant_screen.dart';
import 'profile_screen.dart';
import 'new/family_feed_screen.dart';
import 'new/baby_calendar_screen.dart';
import 'new/progress_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    SectionsScreen(),
    AssistantScreen(),
    ProfileScreen(),
    FamilyFeedScreen(),
    BabyCalendarScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        // Показываем подпись только у выбранной вкладки, чтобы не было переносов
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Ассистент'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Профиль'),
          NavigationDestination(icon: Icon(Icons.feed_outlined), selectedIcon: Icon(Icons.feed), label: 'Лента'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Календарь'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Прогресс'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}


