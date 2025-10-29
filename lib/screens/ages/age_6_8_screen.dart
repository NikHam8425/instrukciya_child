import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Age6to8Screen extends StatefulWidget {
  const Age6to8Screen({super.key});

  @override
  State<Age6to8Screen> createState() => _Age6to8ScreenState();
}

class _Age6to8ScreenState extends State<Age6to8Screen> {
  int _currentAge = 6;
  final List<bool> _checklist = [false, false, false, false, false];
  List<bool> _testAnswers = [false, false, false, false, false];
  String _lastResult = '';
  Color _resultColor = Colors.transparent;
  final TextEditingController _notesController = TextEditingController();

  final Map<int, String> _ageDescriptions = {
    6: 'Шестилетний ребёнок вступает в новый этап — школа. Важно создать спокойную атмосферу и помочь привыкнуть к режиму.',
    7: 'Семилетка становится внимательнее, учится контролировать эмоции. Появляется ответственность и интерес к знаниям.',
    8: 'В восемь лет ребёнок уверенно чувствует себя в школе, у него формируются социальные связи и чувство компетентности.',
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
        (i) => prefs.getBool('adapt_test_$i') ?? false,
      );
      _lastResult = prefs.getString('adapt_result') ?? '';
      final colorString = prefs.getString('adapt_color') ?? 'none';
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
      await prefs.setBool('adapt_test_$i', _testAnswers[i]);
    }
    await prefs.setString('adapt_result', _lastResult);
    String color = 'none';
    if (_resultColor == Colors.green) color = 'green';
    if (_resultColor == Colors.amber) color = 'yellow';
    if (_resultColor == Colors.red) color = 'red';
    await prefs.setString('adapt_color', color);
  }

  void _calculateResult() {
    int score = _testAnswers.where((e) => e).length;

    String resultText;
    Color color;

    if (score >= 4) {
      resultText = '🟢 Адаптация проходит успешно! Ребёнок комфортно чувствует себя в школе.';
      color = Colors.green;
    } else if (score == 3) {
      resultText = '🟡 Частичная адаптация. Ему может понадобиться немного больше поддержки и понимания.';
      color = Colors.amber;
    } else {
      resultText = '🔴 Адаптация идёт тяжело. Не ругайте ребёнка — помогите выстроить доверие, снизьте тревожность.';
      color = Colors.red;
    }

    setState(() {
      _lastResult = resultText;
      _resultColor = color;
    });

    _saveData();
  }

  void _nextAge() {
    setState(() {
      if (_currentAge < 8) _currentAge++;
    });
  }

  void _prevAge() {
    setState(() {
      if (_currentAge > 6) _currentAge--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = _ageDescriptions[_currentAge] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('6–8 лет')),
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

          // --- Чек-лист адаптации ---
          Text('Адаптация к школе', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(_checklist.length, (i) {
            final tasks = [
              'Поддерживать стабильный режим сна и отдыха',
              'Хвалить за старание, а не за оценки',
              'Учить ребёнка выражать эмоции словами',
              'Развивать самостоятельность и чувство ответственности',
              'Следить, чтобы обучение не вызывало тревоги или страха',
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

          // --- Мини-тест адаптации ---
          Text('Мини-тест: адаптация к школе', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(_testAnswers.length, (i) {
            final questions = [
              'Ребёнок идёт в школу без страха и сопротивления',
              'Сам делает уроки (с небольшой помощью)',
              'Может сосредоточиться хотя бы 15 минут',
              'Есть хотя бы 1–2 друга в классе',
              'Умеет просить помощи, если что-то не получается',
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

          const SizedBox(height: 20),

          // --- Советы для родителей ---
          Text('Советы для родителей', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Card(
            color: Color(0xFFF5F5F5),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• При выборе школы ориентируйтесь не только на рейтинг, но и на атмосферу, отзывы родителей и открытость администрации.'),
                  SizedBox(height: 6),
                  Text('• После поступления — не мешайте педагогам выполнять свою работу. Они профессионалы.'),
                  SizedBox(height: 6),
                  Text('• Никогда не обесценивайте педагога при ребёнке.'),
                  SizedBox(height: 6),
                  Text('Если вы дома говорите, что “в школе учат ерунде” или “учитель некомпетентен” — ребёнок теряет уважение к педагогу, перестаёт слушать и теряет мотивацию.'),
                  SizedBox(height: 6),
                  Text('• Поддерживайте доверие между ребёнком, семьёй и школой — это главный фактор успешного обучения.'),
                  SizedBox(height: 6),
                  Text('• Помните: педагог и родитель — союзники, а не соперники.'),
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
              hintText: 'Например: ребёнок стал спокойно идти в школу и рассказывает про друзей.',
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
