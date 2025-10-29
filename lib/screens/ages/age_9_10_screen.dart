import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Age9to10Screen extends StatefulWidget {
  const Age9to10Screen({super.key});

  @override
  State<Age9to10Screen> createState() => _Age9to10ScreenState();
}

class _Age9to10ScreenState extends State<Age9to10Screen> {
  int _currentAge = 9;
  final List<bool> _checklist = [false, false, false, false, false];
  final TextEditingController _notesController = TextEditingController();
  List<bool> _testAnswers = [false, false, false, false, false];
  String _lastResult = '';
  Color _resultColor = Colors.transparent;

  final Map<int, String> _ageDescriptions = {
    9: 'В 9 лет ребёнок начинает осознавать ответственность. Появляется интерес к результату и желание быть успешным.',
    10: 'В 10 лет развивается логика, внимание, самостоятельность. Ребёнок хочет, чтобы ему доверяли и уважали его мнение.',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _testAnswers = List.generate(
        5,
        (i) => prefs.getBool('age9_10_test_$i') ?? false,
      );
      _lastResult = prefs.getString('age9_10_result') ?? '';
      final colorString = prefs.getString('age9_10_color') ?? 'none';
      _resultColor = {
            'green': Colors.green,
            'yellow': Colors.amber,
            'red': Colors.red,
            'none': Colors.transparent,
          }[colorString] ??
          Colors.transparent;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < _testAnswers.length; i++) {
      await prefs.setBool('age9_10_test_$i', _testAnswers[i]);
    }
    await prefs.setString('age9_10_result', _lastResult);
    String color = 'none';
    if (_resultColor == Colors.green) color = 'green';
    if (_resultColor == Colors.amber) color = 'yellow';
    if (_resultColor == Colors.red) color = 'red';
    await prefs.setString('age9_10_color', color);
  }

  void _nextAge() {
    setState(() {
      if (_currentAge < 10) _currentAge++;
    });
  }

  void _prevAge() {
    setState(() {
      if (_currentAge > 9) _currentAge--;
    });
  }

  void _calculateResult() {
    int score = _testAnswers.where((e) => e).length;
    String resultText;
    Color color;

    if (score >= 4) {
      resultText = '🟢 Хорошая самостоятельность — ребёнок готов брать ответственность за себя.';
      color = Colors.green;
    } else if (score == 3) {
      resultText = '🟡 Средний уровень — стоит дать чуть больше свободы и научить планировать.';
      color = Colors.amber;
    } else {
      resultText = '🔴 Низкая самостоятельность — ребёнок всё ещё нуждается в вашей поддержке и структуре.';
      color = Colors.red;
    }

    setState(() {
      _lastResult = resultText;
      _resultColor = color;
    });

    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = _ageDescriptions[_currentAge] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('9–10 лет')),
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
                        onPressed: _prevAge,
                        icon: const Icon(Icons.chevron_left, size: 30),
                      ),
                      Text('$_currentAge лет',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: _nextAge,
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
              'Формировать чувство ответственности за свои вещи и обязанности',
              'Учить планировать день (домашка, отдых, помощь по дому)',
              'Развивать терпение и доведение дел до конца',
              'Поддерживать интерес к обучению без давления',
              'Учить слушать и выражать своё мнение с уважением',
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

          // --- Мини-тест ---
          Text('Мини-тест: уровень самостоятельности', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(_testAnswers.length, (i) {
            final questions = [
              'Ребёнок сам собирает портфель и следит за своими вещами',
              'Сам делает домашние задания, а не ждёт напоминаний',
              'Помогает по дому без просьбы',
              'Может сам спланировать день (учёба, отдых, кружки)',
              'Не теряется при сложных ситуациях и просит помощь осознанно',
            ];
            return CheckboxListTile(
              value: _testAnswers[i],
              onChanged: (val) => setState(() {
                _testAnswers[i] = val ?? false;
                _saveData();
              }),
              title: Text(questions[i]),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: _calculateResult,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Показать результат'),
          ),

          if (_lastResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: _resultColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  _lastResult,
                  style: TextStyle(
                    color: _resultColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // --- Советы ---
          Text('Советы для родителей', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Card(
            color: Color(0xFFF5F5F5),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Учите ребёнка планировать: вместе составляйте расписание и постепенно передавайте ответственность.'),
                  SizedBox(height: 6),
                  Text('• Поддерживайте интерес к учёбе — не оценками, а обсуждением тем.'),
                  SizedBox(height: 6),
                  Text('• Давайте свободу в мелочах: пусть сам выбирает одежду, книги, увлечения.'),
                  SizedBox(height: 6),
                  Text('• Не ругайте за ошибки — учите их анализировать.'),
                  SizedBox(height: 6),
                  Text('• Развивайте уверенность через маленькие победы.'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Заметки ---
          Text('Мои заметки', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Например: сам собрал портфель и не забыл тетрадь.',
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
