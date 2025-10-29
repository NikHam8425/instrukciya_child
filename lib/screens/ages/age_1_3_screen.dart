import 'package:flutter/material.dart';

class Age1to3Screen extends StatefulWidget {
  const Age1to3Screen({super.key});

  @override
  State<Age1to3Screen> createState() => _Age1to3ScreenState();
}

class _Age1to3ScreenState extends State<Age1to3Screen> {
  int _currentMonth = 12;
  final List<bool> _checklist = [false, false, false, false, false];
  final TextEditingController _notesController = TextEditingController();

  final Map<int, String> _monthDescriptions = {
    12: 'Вашему малышу год! Он делает первые уверенные шаги, говорит простые слова и активно исследует мир.',
    18: 'Развивается речь — ребёнок повторяет новые слова, понимает простые просьбы. Может проявлять упрямство — это нормальный этап.',
    24: 'Двухлетка уже бегает, строит башни из кубиков, знает многих животных. Начинает формироваться фразовая речь.',
    30: 'Появляется фантазия, ребёнок играет в ролевые игры, хочет делать многое сам. Поддерживайте самостоятельность.',
    36: 'Три года — возраст “я сам!”. Речь становится чёткой, развивается логика, память, активная социализация с другими детьми.',
  };

  void _nextMonth() {
    setState(() {
      if (_currentMonth < 36) {
        _currentMonth += 6;
      }
    });
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth > 12) {
        _currentMonth -= 6;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = _monthDescriptions[_currentMonth] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('1–3 года')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Навигация по возрасту ---
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
                      Text('$_currentMonth мес.',
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

          // --- Чек-лист ---
          Text('Что важно в этом возрасте', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(_checklist.length, (i) {
            final tasks = [
              'Режим сна и питания по возрасту',
              'Развитие речи и словарного запаса',
              'Приучение к горшку',
              'Игры на развитие моторики и фантазии',
              'Общение со сверстниками и взрослыми',
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
              hintText: 'Например: сегодня впервые сказал "мама"',
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
