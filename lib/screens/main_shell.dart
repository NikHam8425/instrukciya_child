import 'package:flutter/material.dart';

import 'sections_screen.dart';
import 'assistant_screen.dart';
import 'new/profile_screen.dart';
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

  // Порядок СТРОГО соответствует пунктам внизу
  final _pages = const <Widget>[
    SectionsScreen(),      // 0 — Главная (разделы/развитие)
    AssistantScreen(),     // 1 — Ассистент
    ProfileScreen(),       // 2 — Профиль
    FamilyFeedScreen(),    // 3 — Лента
    BabyCalendarScreen(),  // 4 — Календарь
    ProgressScreen(),      // 5 — Прогресс
  ];

  @override
  Widget build(BuildContext context) {
    // Защита от выхода за границы при редактировании
    final page = (_index >= 0 && _index < _pages.length) ? _pages[_index] : _pages.first;

    return Scaffold(
      body: page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),        selectedIcon: Icon(Icons.home),              label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline),  selectedIcon: Icon(Icons.chat_bubble),       label: 'Ассистент'),
          NavigationDestination(icon: Icon(Icons.person_outline),       selectedIcon: Icon(Icons.person),            label: 'Профиль'),
          NavigationDestination(icon: Icon(Icons.article_outlined),     selectedIcon: Icon(Icons.article),           label: 'Лента'),
          NavigationDestination(icon: Icon(Icons.calendar_today),       selectedIcon: Icon(Icons.calendar_today),    label: 'Календарь'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined),   selectedIcon: Icon(Icons.checklist),         label: 'Прогресс'),
        ],
      ),
    );
  }
}
