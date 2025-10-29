import 'package:flutter/material.dart';

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  int _currentWeek = 1;
  final List<bool> _checklist = [false, false, false, false];
  final TextEditingController _notesController = TextEditingController();

  final Map<int, String> _weekDescriptions = {
    1: 'Начало пути! Возможно, вы ещё не знаете о беременности. Следите за самочувствием.',
    2: 'Организм готовится к зачатию. Правильное питание и покой — ваши союзники.',
    3: 'Оплодотворение. Крошечная жизнь только начинается!',
    4: 'Имплантация эмбриона. Возможны лёгкие тянущие ощущения.',
    5: 'Начинается формирование сердца и нервной системы малыша.',
    6: 'Появляется сердцебиение. Можно записаться на первое УЗИ.',
    7: 'Малыш растёт стремительно. Возможна усталость, важно отдыхать.',
    8: 'Начинается формирование черт лица и конечностей ребёнка.',
    9: 'Органы продолжают развиваться, будущая мама может почувствовать перемены в настроении.',
    10: 'Завершается эмбриональный этап. Малыш теперь плод!',
    11: 'Можно сделать первое скрининговое УЗИ. Размер малыша ~4 см.',
    12: 'Уходит токсикоз, энергия возвращается.',
    13: 'Начало второго триместра — стабильное состояние и хорошее самочувствие.',
    14: 'Малыш активно двигается, тренирует мышцы.',
    15: 'Формируются черты лица, вы можете узнать пол ребёнка на УЗИ через несколько недель.',
    16: 'Организм активно снабжает малыша кислородом и питанием.',
    17: 'Можно почувствовать первые шевеления.',
    18: 'Малыш слышит звуки, реагирует на голос мамы.',
    19: 'Следите за осанкой, добавьте лёгкие упражнения и прогулки.',
    20: 'Экватор! Половина пути пройдена.',
    21: 'Плод активно двигается, развивается нервная система.',
    22: 'Появляются волосы и ресницы у малыша.',
    23: 'Возможна усталость — уделяйте время отдыху.',
    24: 'Следите за питанием, увеличивайте количество белка и воды.',
    25: 'Малыш быстро набирает вес, развиваются лёгкие.',
    26: 'Можно начать собирать вещи для роддома.',
    27: 'Конец второго триместра, возможна изжога — дробное питание поможет.',
    28: 'Третий триместр. Пора продумать план родов.',
    29: 'Малыш реагирует на свет, звуки и голос мамы.',
    30: 'Ребёнок активно двигается, растёт и тренирует дыхание.',
    31: 'Быстрый набор веса, может появиться отёчность.',
    32: 'Малыш уже занимает почти всё пространство, тренируйте дыхание.',
    33: 'Подготовьте документы и сумку в роддом.',
    34: 'Время последнего УЗИ перед родами. Отдыхайте больше.',
    35: 'Плод почти готов к жизни вне утробы.',
    36: 'Малыш может опуститься вниз — дыхание станет легче.',
    37: 'Беременность доношенная! Малыш может появиться в любой момент.',
    38: 'Проверяйте сумку и документы, слушайте своё тело.',
    39: 'Организм готовится к родам. Возможны ложные схватки.',
    40: 'Поздравляем! Наступает долгожданная встреча с малышом 💖',
  };

  void _nextWeek() {
    setState(() {
      if (_currentWeek < 40) _currentWeek++;
    });
  }

  void _prevWeek() {
    setState(() {
      if (_currentWeek > 1) _currentWeek--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = _weekDescriptions[_currentWeek] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Подготовка к родам')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Навигация по неделям ---
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
                        onPressed: _prevWeek,
                        icon: const Icon(Icons.chevron_left, size: 30),
                      ),
                      Text('$_currentWeek неделя',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: _nextWeek,
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

          // --- Чек-лист подготовки ---
          Text('Что важно сделать', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(_checklist.length, (i) {
            final tasks = [
              'Пройти УЗИ и анализы',
              'Выбрать роддом и врача',
              'Собрать сумку в роддом',
              'Составить план родов',
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

          // --- Список вещей ---
          Text('Список вещей в роддом', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Card(
            margin: EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📄 Документы: паспорт, полис, обменная карта'),
                  SizedBox(height: 8),
                  Text('🧳 Для мамы: халат, тапочки, вода, зарядка'),
                  SizedBox(height: 8),
                  Text('👶 Для малыша: пеленки, подгузники, чепчик, комбинезон'),
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
              hintText: 'Например: уточнить у врача о роддоме...',
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
