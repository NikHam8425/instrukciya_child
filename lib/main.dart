import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Firebase temporarily disabled
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/main_shell.dart';
import 'screens/registration_screen.dart';
import 'models/child_profile.dart';
import 'theme/app_theme.dart';

// Background message handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Background message: ${message.messageId}');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase temporarily disabled
  // try {
  //   await Firebase.initializeApp();
  //   
  //   // Настройка push-уведомлений
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //   
  //   // Запрос разрешения на уведомления
  //   final messaging = FirebaseMessaging.instance;
  //   await messaging.requestPermission(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  //   print('✅ Firebase инициализирован успешно');
  // } catch (e) {
  //   print('⚠️ Firebase не настроен: $e');
  //   print('Приложение работает в локальном режиме');
  // }
  print('🚀 Приложение запущено в локальном режиме (без Firebase)');
  
  runApp(const InstrukciyaChildApp());
}

class InstrukciyaChildApp extends StatelessWidget {
  const InstrukciyaChildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мамин путь',
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
      // Улучшенные анимации переходов
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) {
            switch (settings.name) {
              case '/main':
                return const MainShell();
              case '/registration':
                return const RegistrationScreen();
              default:
                return const AppInitializer();
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
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
    // Проверяем наличие профиля ребенка (локально)
    final hasProfile = await ChildProfile.hasProfile();
    
    setState(() {
      _hasProfile = hasProfile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Мамин путь',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Загрузка...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _hasProfile ? const MainShell() : const RegistrationScreen(),
    );
  }
}
