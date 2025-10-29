import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Age11to13Screen extends StatefulWidget {
  const Age11to13Screen({super.key});

  @override
  State<Age11to13Screen> createState() => _Age11to13ScreenState();
}

class _Age11to13ScreenState extends State<Age11to13Screen> {
  int _currentAge = 11;
  final List<bool> _checklist = [false, false, false, false, false];
  final TextEditingController _notesController = TextEditingController();
  List<bool> _testAnswers = [false, false, false, false, false];
  String _lastResult = '';
  Color _resultColor = Colors.transparent;

  final Map<int, String> _ageDescriptions = {
    11: 'Ребёнок начинает отстаивать своё мнение. Важно сохранять диалог и уважение.',
    12: 'Появляется желание быть взрослым. Эмоции обостряются, но нужна стабильность родителей.',
    13: 'Пик самоутверждения. Может спорить, конфликтовать, испытывать границы дозволенного.',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _testAnswers = List.generate(5, (i) => prefs.getBool('age11_13_test_$i') ?? false);
      _lastResult = prefs.getString('age11_13_result') ?? '';
      final colorString = prefs.getString('age11_13_color') ?? 'none';
      _resultColor = {
        'green': Colors.green,
        'yellow': Colors.amber,
        'red': Colors.red,
        'none': Colors.transparent,
      }[colorString] ?? Colors.transparent;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < _testAnswers.length; i++) {
      await prefs.setBool('age11_13_test_$i', _testAnswers[i]);
    }
    await prefs.setString('age11_13_result', _lastResult);
    String color = 'none';
    if (_resultColor == Colors.green) color = 'green';
    if (_resultColor == Colors.amber) color = 'yellow';
    if (_resultColor == Colors.red) color = 'red';
    await prefs.setString('age11_13_color', color);
  }

  void _calculateResult() {
    int score = _testAnswers.where((e) => e).length;
    String resultText;
    Color color;
    if (score >= 4) {
      resultText = '🟢 Ребёнок чувствует себя уверенно и сохраняет контакт с вами.';
      color = Colors.green;
    } else if (score == 3) {
      resultText = '🟡 Средний уровень — важно сохранять доверие и спокойный тон.';
      color = Colors.amber;
    } else {
      resultText = '🔴 Контакт ослаблен — давайте ему пространство, но оставайтесь рядом.';
      color = Colors.red;
    }
    setState(() {
      _lastResult = resultText;
      _resultColor = color;
    });
    _saveData();
  }

  void _nextAge() => setState(() => _currentAge < 13 ? _currentAge++ : null);
  void _prevAge() => setState(() => _currentAge > 11 ? _currentAge-- : null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = _ageDescriptions[_currentAge] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('11–13 лет')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Возраст ---
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: _prevAge, icon: const Icon(Icons.chevron_left, size: 30)),
                    Text('$_currentAge лет', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    IconButton(onPressed: _nextAge, icon: const Icon(Icons.chevron_right, size: 30)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(description, textAlign: TextAlign.justify),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // --- Чек-лист ---
          Text('Что важно в этом возрасте', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...[
            'Сохранять уважительный диалог',
            'Давать право на мнение и ошибку',
            'Не обесценивать эмоции подростка',
            'Помогать справляться со стрессом',
            'Поддерживать личные интересы и хобби',
          ].asMap().entries.map((e) => CheckboxListTile(
                value: _checklist[e.key],
                onChanged: (val) => setState(() => _checklist[e.key] = val ?? false),
                title: Text(e.value),
                controlAffinity: ListTileControlAffinity.leading,
              )),
          const SizedBox(height: 16),

          // --- Мини-тест ---
          Text('Мини-тест: контакт с подростком', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...[
            'Ребёнок делится с вами своими переживаниями',
            'Не боится говорить о своих ошибках',
            'Вы стараетесь слушать, не перебивая',
            'Вы обсуждаете правила, а не диктуете их',
            'Он чувствует уважение к своим границам',
          ].asMap().entries.map((e) => CheckboxListTile(
                value: _testAnswers[e.key],
                onChanged: (val) => setState(() {
                  _testAnswers[e.key] = val ?? false;
                  _saveData();
                }),
                title: Text(e.value),
                controlAffinity: ListTileControlAffinity.leading,
              )),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _calculateResult,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Показать результат'),
          ),
          if (_lastResult.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: _resultColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(_lastResult, style: TextStyle(color: _resultColor, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 16),

          // --- Советы ---
          Text('Советы для родителей', style: theme.textTheme.titleMedium),
          const Card(
            margin: EdgeInsets.only(top: 8),
            color: Color(0xFFF5F5F5),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('• Подростковый протест — естественный этап взросления.'),
                Text('• Не пытайтесь “сломать” сопротивление, помогите прожить его.'),
                Text('• Объясняйте, а не приказывайте.'),
                Text('• Сохраняйте чувство юмора и доброжелательность.'),
                Text('• Если спорите — спорьте уважительно.'),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // --- Заметки ---
          Text('Мои заметки', style: theme.textTheme.titleMedium),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Например: спокойно поговорили после конфликта.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заметка сохранена')));
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
