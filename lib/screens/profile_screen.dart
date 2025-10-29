import 'package:flutter/material.dart';
import '../models/child_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ChildProfile?> _future;

  @override
  void initState() {
    super.initState();
    _future = ChildProfile.load();  // <-- грузим из SharedPreferences
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
                    onPressed: () => Navigator.pushNamed(context, '/registration'),
                    child: const Text('Создать профиль'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _tile('Имя', profile.name, Icons.person),
              _tile('Пол', profile.gender == Gender.male ? 'Мальчик' : 'Девочка', Icons.wc),
              _tile('Дата рождения',
                  '${profile.birthDate.day.toString().padLeft(2, '0')}.${profile.birthDate.month.toString().padLeft(2, '0')}.${profile.birthDate.year}',
                  Icons.cake),
              _tile('Вес', '${profile.weight.toStringAsFixed(1)} кг', Icons.monitor_weight),
              _tile('Рост', '${profile.height.toStringAsFixed(0)} см', Icons.height),
              if (profile.notes.isNotEmpty) _tile('Заметки', profile.notes, Icons.note),
              const SizedBox(height: 16),
              if (profile.specialNeeds.isNotEmpty)
                _chips('Особые потребности', profile.specialNeeds),
              if (profile.allergies.isNotEmpty)
                _chips('Аллергии', profile.allergies),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/registration'),
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
      child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(subtitle)),
    );
  }

  Widget _chips(String title, List<String> values) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: values.map((e) => Chip(label: Text(e))).toList(),
          ),
        ]),
      ),
    );
  }
}
