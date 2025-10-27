import 'package:flutter/material.dart';

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
    ];
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
            onTap: () {
              // TODO: navigate to topics list for period it.$1
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
    );
  }
}


