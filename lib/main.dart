import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/profile_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_shell.dart';
import 'screens/registration_screen.dart';
import 'models/child_profile.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProfileState()..load(),
      child: const InstrukciyaChildApp(),
    ),
  );
}

class InstrukciyaChildApp extends StatelessWidget {
  const InstrukciyaChildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Инструкция к ребёнку',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
      home: const AppInitializer(),
      routes: {
        '/main': (context) => const MainShell(),
        '/registration': (context) => const RegistrationScreen(),
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    // Временно очищаем профиль для тестирования
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('childProfile');
    
    final hasProfile = await ChildProfile.hasProfile();
    
    setState(() {
      _hasProfile = hasProfile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasProfile) {
      return const MainShell();
    } else {
      return const RegistrationScreen();
    }
  }
}
