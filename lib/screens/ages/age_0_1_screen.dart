import 'package:flutter/material.dart';

class Age0to1Screen extends StatefulWidget {
  const Age0to1Screen({super.key});

  @override
  State<Age0to1Screen> createState() => _Age0to1ScreenState();
}

class _Age0to1ScreenState extends State<Age0to1Screen> {
  int _currentMonth = 0;
  final List<bool> _checklist = [false, false, false, false, false];
  final TextEditingController _notesController = TextEditingController();

  final Map<int, String> _monthDescriptions = {
    0: 'Малыш только родился. Главное — забота, тепло, кожа к коже, кормление по требованию.',
    1: 'Ребёнок начинает держать взгляд, узнаёт голос родителей.',
    2: 'Появляются первые улыбки и гуление. Укрепляется шея.',
    3: 'Малыш может приподнимать голову, реагирует на игрушки.',
    4: 'Начинает хватать предметы, активнее двигается.',
    5: 'Появляется лепет, переворачивается со спины на живот.',
    6: 'Умеет сидеть с поддержкой, реагирует на своё имя.',
    7: 'Начинается прикорм, интерес к еде, много лепета.',
    8: 'Может ползать, играть в «ку-ку», любит внимание.',
    9: 'Сидит без поддержки, старается вставать у опоры.',
    10: 'Понимает простые слова, показывает эмоции.',
    11: 'Может стоять без опоры, ходит с поддержкой.',
    12: 'Первый день рождения! Может делать первые шаги, говорить простые слова.',
  };

  void _nextMonth() {
    setState(() {
      if (_currentMonth < 12) _currentMonth++;
    });
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth > 0) _currentMonth--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = _monthDescriptions[_currentMonth] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('0–1 год')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Навигация по месяцам ---
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _prevMonth,
                        icon: const Icon(Icons.chevron_left, size: 30),
                      ),
                      Text('$_currentMonth месяц',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(description, textAlign: TextAlign.justify),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Чек-лист ухода ---
          Text('Что важно в этом месяце', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(_checklist.length, (i) {
            final tasks = [
              'Ежедневное купание и массаж',
              'Прогулки на свежем воздухе',
              'Общение и игры с ребёнком',
              'Наблюдение у педиатра',
              'Регулярный режим сна и кормлений',
            ];
            return CheckboxListTile(
              value: _checklist[i],
              onChanged: (val) => setState(() => _checklist[i] = val ?? false),
              title: Text(tasks[i]),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          }),

          const SizedBox(height: 16),

          // --- Заметки ---
          Text('Мои заметки', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Например: сегодня первый раз перевернулся!',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Заметка сохранена')),
              );
              _notesController.clear();
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Сохранить заметку'),
          ),
        ],
      ),
    );
  }
}
