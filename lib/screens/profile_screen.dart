import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/user_profile.dart';
import '../theme/theme_controller.dart';
import 'registration_screen.dart';

import '../theme/locale_controller.dart'; // Added import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ChildProfile?> _future;
  late Future<UserProfile?> _futureParent;

  @override
  void initState() {
    super.initState();
    _future = ChildProfile.load();
    _futureParent = UserProfile.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: FutureBuilder<ChildProfile?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data;

          if (profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Профиль не заполнен'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final child = await _future;
                      final parent = await _futureParent;
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegistrationScreen(
                            existingChild: child,
                            existingParent: parent,
                          ),
                        ),
                      );
                    },
                    child: const Text('Создать профиль'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Increased bottom padding to clear Nav Bar
            children: [
              _tile('Имя', profile.name, Icons.person),
              _tile('Пол',
                  profile.gender == Gender.male ? 'Мальчик' : 'Девочка', Icons.wc),
              _tile(
                'Дата рождения',
                '${profile.birthDate.day.toString().padLeft(2, '0')}.${profile.birthDate.month.toString().padLeft(2, '0')}.${profile.birthDate.year}',
                Icons.cake,
              ),
              _tile('Вес', '${profile.weight.toStringAsFixed(1)} кг', Icons.monitor_weight),
              _tile('Рост', '${profile.height.toStringAsFixed(0)} см', Icons.height),
              if (profile.notes.isNotEmpty)
                _tile('Заметки', profile.notes, Icons.note),
              const SizedBox(height: 16),
              if (profile.specialNeeds.isNotEmpty)
                _chips('Особые потребности', profile.specialNeeds),
              if (profile.allergies.isNotEmpty)
                _chips('Аллергии', profile.allergies),

              const SizedBox(height: 24),

              // Переключатель темы (день / ночь / как в системе)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Тема приложения'),
                  subtitle: Text(_themeLabel(ThemeController.instance.mode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: ThemeController.instance.mode,
                    underline: const SizedBox.shrink(),
                    onChanged: (mode) {
                      if (mode == null) return;
                      ThemeController.instance.setMode(mode);
                      setState(() {});
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('Как в системе'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Светлая'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Тёмная'),
                      ),
                    ],
                  ),
                ),
              ),

              // Переключатель языка
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Язык'),
                  subtitle: Text(
                      LocaleController.instance.locale?.languageCode == 'en'
                          ? 'English'
                          : 'Русский'),
                  trailing: DropdownButton<String>(
                    value: LocaleController.instance.locale?.languageCode ?? 'ru',
                    underline: const SizedBox.shrink(),
                    onChanged: (code) {
                      if (code == null) return;
                      LocaleController.instance.setLocale(Locale(code));
                      setState(() {});
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'ru',
                        child: Text('Русский'),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                    ],
                  ),
                ),
              ),

              FutureBuilder<UserProfile?>(
                future: _futureParent,
                builder: (context, parentSnapshot) {
                  final parent = parentSnapshot.data;
                  if (parent == null) return const SizedBox();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24), // Added spacing
                      const Text(
                        'Данные родителя',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Имя родителя'),
                          subtitle: Text(parent.name),
                        ),
                      ),
                      if (parent.email != null && parent.email!.isNotEmpty)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('Email'),
                            subtitle: Text(parent.email!),
                          ),
                        ),
                      if (parent.phone != null && parent.phone!.isNotEmpty)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text('Телефон'),
                            subtitle: Text(parent.phone!),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final child = await _future;
                  final parent = await _futureParent;
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegistrationScreen(
                        existingChild: child,
                        existingParent: parent,
                      ),
                    ),
                  );
                },
                child: const Text('Редактировать'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(String title, String subtitle, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _chips(String title, List<String> values) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  values.map((e) => Chip(label: Text(e))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Тёмная';
      case ThemeMode.system:
      default:
        return 'Как в системе';
    }
  }
}
