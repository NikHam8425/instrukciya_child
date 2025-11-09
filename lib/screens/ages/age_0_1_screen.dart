import 'package:flutter/material.dart';

class Age0to1Screen extends StatefulWidget {
  const Age0to1Screen({super.key});

  @override
  State<Age0to1Screen> createState() => _Age0to1ScreenState();
}

class _Age0to1ScreenState extends State<Age0to1Screen> {
  int _currentMonth = 0;
  final Map<int, List<bool>> _checklistStates = {};
  final TextEditingController _notesController = TextEditingController();

  List<bool> _getChecklistForMonth(int month) {
    if (!_checklistStates.containsKey(month)) {
      final tasks = _getTasksForMonth(month);
      _checklistStates[month] = List.filled(tasks.length, false);
    }
    return _checklistStates[month]!;
  }

  List<String> _getTasksForMonth(int month) {
    switch (month) {
      case 0:
        return [
          'Кормление по требованию',
          'Контакт кожа к коже',
          'Обработка пупочной ранки',
          'Первый осмотр у педиатра',
          'Наладить режим сна',
        ];
      case 1:
        return [
          'Ежедневное купание',
          'Лёгкий массаж и гимнастика',
          'Выкладывание на животик',
          'Прогулки на свежем воздухе',
          'Плановый осмотр в 1 месяц',
        ];
      case 2:
        return [
          'Показывать яркие игрушки',
          'Разговаривать с малышом',
          'Укреплять мышцы шеи',
          'Первая прививка (по графику)',
          'Следить за режимом сна',
        ];
      case 3:
        return [
          'Игры с погремушками',
          'Упражнения на фитболе',
          'Развитие хватательного рефлекса',
          'Осмотр у педиатра в 3 месяца',
          'Вторая прививка',
        ];
      case 4:
        return [
          'Учить переворачиваться',
          'Развивать мелкую моторику',
          'Читать книжки с картинками',
          'Петь песенки и потешки',
          'Плановый осмотр',
        ];
      case 5:
        return [
          'Поддерживать попытки сесть',
          'Играть в "ку-ку"',
          'Показывать разные текстуры',
          'Третья прививка',
          'Начать подготовку к прикорму',
        ];
      case 6:
        return [
          'Ввести первый прикорм (овощи)',
          'Поддерживать сидение',
          'Осмотр у педиатра в 6 месяцев',
          'Развивать речь через общение',
          'Следить за прорезыванием зубов',
        ];
      case 7:
        return [
          'Расширять рацион прикорма',
          'Поощрять ползание',
          'Играть в развивающие игры',
          'Учить пить из поилки',
          'Плановый осмотр',
        ];
      case 8:
        return [
          'Поддерживать вставание у опоры',
          'Добавить каши и мясо в рацион',
          'Развивать мелкую моторику',
          'Играть в ладушки',
          'Продолжать общение',
        ];
      case 9:
        return [
          'Поощрять первые шаги',
          'Расширять словарный запас',
          'Осмотр у педиатра в 9 месяцев',
          'Добавить рыбу в рацион',
          'Играть в прятки',
        ];
      case 10:
        return [
          'Поддерживать ходьбу с опорой',
          'Учить простым словам',
          'Развивать самостоятельность',
          'Давать пробовать новые продукты',
          'Плановый осмотр',
        ];
      case 11:
        return [
          'Поощрять самостоятельную ходьбу',
          'Развивать речь и понимание',
          'Играть в сюжетные игры',
          'Учить есть ложкой',
          'Подготовка к первому дню рождения',
        ];
      case 12:
        return [
          'Отметить первый день рождения!',
          'Полный осмотр у врачей',
          'Продолжать развивать речь',
          'Поощрять самостоятельность',
          'Планировать развитие на второй год',
        ];
      default:
        return [
          'Ежедневное купание и массаж',
          'Прогулки на свежем воздухе',
          'Общение и игры с ребёнком',
          'Наблюдение у педиатра',
          'Регулярный режим сна и кормлений',
        ];
    }
  }

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
          ...() {
            final checklist = _getChecklistForMonth(_currentMonth);
            final tasks = _getTasksForMonth(_currentMonth);
            return List.generate(tasks.length, (i) {
              return CheckboxListTile(
                value: checklist[i],
                onChanged: (val) => setState(() => checklist[i] = val ?? false),
                title: Text(tasks[i]),
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              );
            });
          }(),

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
