import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:instrukciya_child/l10n/generated/app_localizations.dart';

import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/locale_controller.dart';
import 'router/app_router.dart';
import 'models/child_profile.dart';

import 'services/notifications_service.dart';

// Обработчик фоновых сообщений Firebase
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация локальных уведомлений
  try {
    await NotificationsService.initialize();
  } catch (e) {
    debugPrint('⚠️ NotificationsService initialization failed: $e');
  }

  // Инициализация Firebase с безопасной обработкой ошибок
  // Это предотвращает краш на Android/Web если конфиг отсутствует
  if (!kIsWeb) {
    try {
      // ВАЖНО: Доступ к DefaultFirebaseOptions.currentPlatform может выбросить ошибку,
      // если платформа не сконфигурирована. Поэтому мы делаем это внутри try-block.
      final options = DefaultFirebaseOptions.currentPlatform;
      await Firebase.initializeApp(options: options);

      // ВАЖНО: Авторизуемся анонимно, чтобы работали Cloud Functions
      // Функции требуют авторизации (request.auth.uid)
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('Signed in as: ${FirebaseAuth.instance.currentUser?.uid}');

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (e, stack) {
      debugPrint('⚠️ Firebase initialization failed: $e');
      debugPrint('Stack trace: $stack');
      // Приложение продолжит работу без Firebase
    }
  }

  // Загружаем сохранённый режим темы и язык
  try {
    await ThemeController.instance.load();
    await LocaleController.instance.load();
  } catch (e) {
    debugPrint('⚠️ Settings loading failed: $e');
  }

  runApp(const InstrukciyaChildApp());
}

class InstrukciyaChildApp extends StatelessWidget {
  const InstrukciyaChildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppInitializer();
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _prepareRouter();
  }

  Future<void> _prepareRouter() async {
    bool hasProfile = false;
    try {
      hasProfile = await ChildProfile.hasProfile();
    } catch (e) {
      debugPrint('Error checking profile: $e');
    }
    
    if (!mounted) return;
    
    setState(() {
      _router = createRouter(hasProfile: hasProfile);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.instance;
    final localeController = LocaleController.instance;

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: localeController,
          builder: (context, _) {
            if (_isLoading || _router == null) {
              return MaterialApp(
                onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Мамин путь',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeController.mode,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        // Safe access to theme/context
                        Builder(builder: (context) {
                           return Text(
                            AppLocalizations.of(context)?.appTitle ?? 'Мамин путь',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        const Text('Загрузка...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            }

            return MaterialApp.router(
              onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeController.mode,
              locale: localeController.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: _router!,
            );
          },
        );
      },
    );
  }
}
