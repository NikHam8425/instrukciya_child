// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/sections_screen.dart';
import '../screens/assistant_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/new/family_feed_screen.dart';
import '../screens/new/baby_calendar_screen.dart';
import '../screens/new/progress_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/main_shell.dart';
import '../models/child_profile.dart';

GoRouter createRouter({required bool hasProfile}) {
  return GoRouter(
    initialLocation: hasProfile ? '/' : '/registration',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', name: 'home', builder: (context, state) => const SectionsScreen()),
          GoRoute(path: '/assistant', name: 'assistant', builder: (context, state) => const AssistantScreen()),
          GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: '/feed', name: 'feed', builder: (context, state) => const FamilyFeedScreen()),
          GoRoute(path: '/calendar', name: 'calendar', builder: (context, state) => const BabyCalendarScreen()),
          GoRoute(path: '/progress', name: 'progress', builder: (context, state) => const ProgressScreen()),
        ],
      ),
      GoRoute(
        path: '/registration',
        name: 'registration',
        builder: (context, state) => const RegistrationScreen(),
      ),
    ],
    redirect: (context, state) async {
      final hasProfile = await ChildProfile.hasProfile();
      final isOnReg = state.matchedLocation == '/registration';

      if (!hasProfile && !isOnReg) return '/registration';
      if (hasProfile && isOnReg) return '/';
      return null;
    },
  );
}