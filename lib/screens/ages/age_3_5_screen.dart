import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Age3to5Screen extends StatefulWidget {
  const Age3to5Screen({super.key});

  @override
  State<Age3to5Screen> createState() => _Age3to5ScreenState();
}

class _Age3to5ScreenState extends State<Age3to5Screen> {
  int _currentAge = 3;
  List<bool> _readinessTest = [false, false, false, false, false];
  List<bool> _checklist = [false, false, false, false];
  String _lastResult = '';
  Color _resultColor = Colors.transparent;
  final TextEditingController _notesController = TextEditingController();

  final Map<int, String> _ageDescriptions = {
    3: 'В три года ребёнок активно развивает речь, эмоции и самостоятельность. Важно давать ему право выбора и поддержку.',
    4: 'Четырёхлетка начинает фантазировать, строить ролевые игры и осознавать правила. У него формируется эмпатия и уверенность.',
    5: 'Пятилетка готовится к школе: развивается память, внимание, координация и желание узнавать новое. Главное — не спешить.',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _readinessTest = List.generate(
        5,
        (i) => prefs.getBool('test_$i') ?? false,
      );
      _checklist = List.generate(
        4,
        (i) => prefs.getBool('check_$i') ?? false,
      );
      _lastResult = prefs.getString('last_result') ?? '';
      final colorString = prefs.getString('result_color') ?? 'none';
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
    for (var i = 0; i < _readinessTest.length; i++) {
      await prefs.setBool('test_$i', _readinessTest[i]);
    }
    for (var i = 0; i < _checklist.length; i++) {
      await prefs.setBool('check_$i', _checklist[i]);
    }
    await prefs.setString('last_result', _lastResult);
    String color = 'none';
    if (_resultColor == Colors.green) color = 'green';
    if (_resultColor == Colors.amber) color = 'yellow';
    if (_resultColor == Colors.red) color = 'red';
    await prefs.setString('result_color', color);
  }

  void _nextAge() {
    setState(() {
      if (_currentAge < 5) _currentAge++;
    });
  }

  void _prevAge() {
    setState(() {
      if (_currentAge > 3) _currentAge--;
    });
  }

  void _calculateResult() {
    int score = _readinessTest.where((e) => e).length;

    String resultText;
    Color color;

    if (score >= 4) {
      resultText = '🟢 Готов к школе — развитие соответствует возрасту.';
      color = Colors.green;
    } else if (score == 3) {
      resultText = '🟡 Почти готов — дайте ещё 3–6 месяцев для развития внимания и моторики.';
      color = Colors.amber;
    } else {
      resultText = '🔴 Рано — лучше подождать с обучением, развивать речь, движения и самостоятельность.';
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
      appBar: AppBar(title: const Text('3–5 лет')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Возраст ---
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

          // --- Общий чек-лист для 3-4 лет ---
          if (_currentAge < 5) ...[
            Text('Что важно в этом возрасте', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...List.generate(_checklist.length, (i) {
              final tasks = [
                'Развивать речь и словарный запас',
                'Учить играть с другими детьми',
                'Развивать мелкую моторику через лепку и рисование',
                'Формировать чувство самостоятельности',
              ];
              return CheckboxListTile(
                value: _checklist[i],
                onChanged: (val) => setState(() {
                  _checklist[i] = val ?? false;
                  _saveData();
                }),
                title: Text(tasks[i]),
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              );
            }),
          ],

          // --- Подготовка к школе (только для 5 лет) ---
          if (_currentAge == 5) ...[
            Text('Подготовка к школе', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Не спешите отдавать ребёнка в школу раньше 6,5–7 лет. '
                  'Готовность — это не знание букв, а зрелость мозга и тела. '
                  'Ранний старт может привести к стрессу, усталости и потере интереса к учёбе.',
                  textAlign: TextAlign.justify,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text('Тест на готовность к школе', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...List.generate(_readinessTest.length, (i) {
              final questions = [
                'Может достать рукой до противоположного уха через голову',
                'Может нарисовать треугольник или домик по образцу',
                'Способен спокойно заниматься 10–15 минут',
                'Говорит предложениями из 5–6 слов',
                'Понимает, что учёба — это “работа”, а не игра',
              ];
              return CheckboxListTile(
                value: _readinessTest[i],
                onChanged: (val) => setState(() {
                  _readinessTest[i] = val ?? false;
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
          ],

          const SizedBox(height: 16),

          // --- Заметки ---
          Text('Мои заметки', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Например: “Пока не достаёт до уха — ждём годик.”',
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
