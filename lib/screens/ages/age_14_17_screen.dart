import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Age14to17Screen extends StatefulWidget {
  const Age14to17Screen({super.key});

  @override
  State<Age14to17Screen> createState() => _Age14to17ScreenState();
}

class _Age14to17ScreenState extends State<Age14to17Screen> {
  int _currentAge = 14;
  final List<bool> _checklist = [false, false, false, false, false];
  final TextEditingController _notesController = TextEditingController();
  List<bool> _testAnswers = [false, false, false, false, false];
  String _lastResult = '';
  Color _resultColor = Colors.transparent;

  final Map<int, String> _ageDescriptions = {
    14: 'Начало взрослой жизни — подросток ищет себя и требует уважения к своей независимости.',
    15: 'Период формирования целей и взглядов на мир. Родителям важно быть рядом, но не вмешиваться.',
    16: 'Время проб и ошибок: отношения, мечты, уверенность и сомнения.',
    17: 'Юность. Поддержите выбор и веру ребёнка в себя. Главное — доверие и принятие.',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _testAnswers = List.generate(5, (i) => prefs.getBool('age14_17_test_$i') ?? false);
      _lastResult = prefs.getString('age14_17_result') ?? '';
      final colorString = prefs.getString('age14_17_color') ?? 'none';
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
      await prefs.setBool('age14_17_test_$i', _testAnswers[i]);
    }
    await prefs.setString('age14_17_result', _lastResult);
    String color = 'none';
    if (_resultColor == Colors.green) color = 'green';
    if (_resultColor == Colors.amber) color = 'yellow';
    if (_resultColor == Colors.red) color = 'red';
    await prefs.setString('age14_17_color', color);
  }

  void _calculateResult() {
    int score = _testAnswers.where((e) => e).length;
    String resultText;
    Color color;
    if (score >= 4) {
      resultText = '🟢 У вас здоровый контакт. Ребёнок доверяет и чувствует себя уверенно рядом.';
      color = Colors.green;
    } else if (score == 3) {
      resultText = '🟡 Контакт есть, но требует бережного внимания и открытого диалога.';
      color = Colors.amber;
    } else {
      resultText = '🔴 Подросток замыкается. Попробуйте дать больше свободы и меньше критики.';
      color = Colors.red;
    }
    setState(() {
      _lastResult = resultText;
      _resultColor = color;
    });
    _saveData();
  }

  void _nextAge() => setState(() => _currentAge < 17 ? _currentAge++ : null);
  void _prevAge() => setState(() => _currentAge > 14 ? _currentAge-- : null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = _ageDescriptions[_currentAge] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('14–17 лет')),
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
            'Давать пространство для выбора и ошибок',
            'Обсуждать цели и мечты, а не навязывать свои',
            'Поддерживать эмоционально, а не контролировать',
            'Помогать развивать ответственность и финансовую грамотность',
            'Говорить с уважением, как со взрослым человеком',
          ].asMap().entries.map((e) => CheckboxListTile(
                value: _checklist[e.key],
                onChanged: (val) => setState(() => _checklist[e.key] = val ?? false),
                title: Text(e.value),
                controlAffinity: ListTileControlAffinity.leading,
              )),
          const SizedBox(height: 16),

          // --- Мини-тест ---
          Text('Мини-тест: доверие и самостоятельность', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...[
            'Ребёнок открыто делится своими планами и переживаниями',
            'Вы обсуждаете, а не контролируете решения',
            'Подросток умеет признавать ошибки и делать выводы',
            'Вы доверяете ему с деньгами, временем, друзьями',
            'В семье сохраняется чувство уважения и юмора',
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
          Text('Советы родителям', style: theme.textTheme.titleMedium),
          const Card(
            margin: EdgeInsets.only(top: 8),
            color: Color(0xFFF5F5F5),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('• Не пытайтесь быть "друзьями" — будьте опорой.'),
                Text('• Уважайте личное пространство и время.'),
                Text('• Вместо критики — открытые вопросы и обсуждение.'),
                Text('• Говорите о жизни, выборе профессии, отношениях.'),
                Text('• Поддерживайте веру ребёнка в его возможности.'),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // --- Заметки ---
          Text('Мои заметки', style: theme.textTheme.titleMedium),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Например: сын сам решил вернуться в спорт.',
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
