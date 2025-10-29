import 'package:flutter/material.dart';
import 'package:instrukciya_child/screens/ages/pregnancy_screen.dart';
import 'package:instrukciya_child/screens/ages/age_0_1_screen.dart';
import 'package:instrukciya_child/screens/ages/age_1_3_screen.dart';
import 'package:instrukciya_child/screens/ages/age_3_5_screen.dart';
import 'package:instrukciya_child/screens/ages/age_6_8_screen.dart';
import 'package:instrukciya_child/screens/ages/age_9_10_screen.dart';
import 'package:instrukciya_child/screens/ages/age_11_13_screen.dart';
import 'package:instrukciya_child/screens/ages/age_14_17_screen.dart';

class SectionsScreen extends StatelessWidget {
  const SectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = const [
      ('prenatal', 'Подготовка к родам', '👶'),
      ('age_0_1', '0–1 год', '🍼'),
      ('age_1_3', '1–3 года', '🚼'),
      ('age_3_5', '3–5 лет', '🎒'),
      ('age_6_8', '6–8 лет', '🧠'),
      ('age_9_10', '9–10 лет', '💡'),
      ('age_11_13', '11–13 лет', '⚡️'),
      ('age_14_17', '14–17 лет', '🔥'),
    ];

    void openScreen(BuildContext context, String id) {
      Widget screen;
      switch (id) {
        case 'prenatal':
          screen = const PregnancyScreen();
          break;
        case 'age_0_1':
          screen = const Age0to1Screen();
          break;
        case 'age_1_3':
          screen = const Age1to3Screen();
          break;
        case 'age_3_5':
          screen = const Age3to5Screen();
          break;
        case 'age_6_8':
          screen = const Age6to8Screen();
          break;
        case 'age_9_10':
          screen = const Age9to10Screen();
          break;
        case 'age_11_13':
          screen = const Age11to13Screen();
          break;
        case 'age_14_17':
          screen = const Age14to17Screen();
          break;
        default:
          screen = const Scaffold(
            body: Center(child: Text('Раздел в разработке')),
          );
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Развитие')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) {
          final it = items[i];
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.white,
            leading: Text(it.$3, style: theme.textTheme.headlineSmall),
            title: Text(it.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openScreen(context, it.$1),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
    );
  }
}
