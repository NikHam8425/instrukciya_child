import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notifications_service.dart';
import '../../models/child_profile.dart';

class BabyCalendarScreen extends StatefulWidget {
  const BabyCalendarScreen({super.key});

  @override
  State<BabyCalendarScreen> createState() => _BabyCalendarScreenState();
}

class _BabyCalendarScreenState extends State<BabyCalendarScreen> {
  DateTime? _babyDob;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBabyDob();
  }

  Future<void> _loadBabyDob() async {
    // 1. Пробуем взять дату рождения из профиля ребёнка
    final profile = await ChildProfile.load();
    if (profile != null) {
      final dob = profile.birthDate;
      setState(() {
        _babyDob = dob;
        _dateController.text = _formatDate(dob);
      });
      return;
    }

    // 2. Fallback: поддержка старого варианта хранения отдельного ключа
    final prefs = await SharedPreferences.getInstance();
    final dobString = prefs.getString('babyDob');
    if (dobString != null) {
      final dob = DateTime.parse(dobString);
      setState(() {
        _babyDob = dob;
        _dateController.text = _formatDate(dob);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _babyDob ?? DateTime.now(),
      firstDate: DateTime(2014), // 10 лет назад
      lastDate: DateTime.now(),
      locale: const Locale('ru', 'RU'),
    );

    if (selectedDate != null) {
      setState(() {
        _babyDob = selectedDate;
        _dateController.text = _formatDate(selectedDate);
      });

      // Сохраняем дату (старый ключ, чтобы не ломать совместимость)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('babyDob', selectedDate.toIso8601String());

      // Обновляем дату рождения в профиле, если он уже есть
      final profile = await ChildProfile.load();
      if (profile != null) {
        final updated = ChildProfile(
          name: profile.name,
          gender: profile.gender,
          birthDate: selectedDate,
          weight: profile.weight,
          height: profile.height,
          specialNeeds: profile.specialNeeds,
          allergies: profile.allergies,
          notes: profile.notes,
          createdAt: profile.createdAt,
        );
        await updated.save();
      }

      // Планируем уведомления
      await NotificationsService.scheduleBabyNotifications(selectedDate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дата рождения сохранена')),
        );
      }
    }
  }

  String _calculateAge() {
    if (_babyDob == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(_babyDob!);
    final days = difference.inDays;
    
    if (days < 30) {
      return '$days дней';
    } else if (days < 365) {
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      return '$months мес $remainingDays дн';
    } else {
      final years = (days / 365).floor();
      final remainingDays = days % 365;
      final months = (remainingDays / 30).floor();
      return '$years г $months мес';
    }
  }

  List<Map<String, dynamic>> _getUpcomingMilestones() {
    if (_babyDob == null) return [];

    final milestones = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // 1 месяц - к врачу
    final oneMonth = _babyDob!.add(const Duration(days: 30));
    milestones.add({
      'title': 'Осмотр у врача',
      'date': oneMonth,
      'description': 'Плановый осмотр педиатра',
      'isPassed': now.isAfter(oneMonth),
    });

    // 6 месяцев - прикорм
    final sixMonths = _babyDob!.add(const Duration(days: 180));
    milestones.add({
      'title': 'Введение прикорма',
      'date': sixMonths,
      'description': 'Начало введения твёрдой пищи',
      'isPassed': now.isAfter(sixMonths),
    });

    // 12 месяцев - первые зубы
    final twelveMonths = _babyDob!.add(const Duration(days: 365));
    milestones.add({
      'title': 'Первые зубы',
      'date': twelveMonths,
      'description': 'Ожидается появление первых зубов',
      'isPassed': now.isAfter(twelveMonths),
    });

    // 18 месяцев - первые слова
    final eighteenMonths = _babyDob!.add(const Duration(days: 548));
    milestones.add({
      'title': 'Первые слова',
      'date': eighteenMonths,
      'description': 'Активное развитие речи',
      'isPassed': now.isAfter(eighteenMonths),
    });

    // 2 года - приучение к горшку
    final twoYears = _babyDob!.add(const Duration(days: 730));
    milestones.add({
      'title': 'Приучение к горшку',
      'date': twoYears,
      'description': 'Начало приучения к самостоятельности',
      'isPassed': now.isAfter(twoYears),
    });

    // 3 года - детский сад
    final threeYears = _babyDob!.add(const Duration(days: 1095));
    milestones.add({
      'title': 'Детский сад',
      'date': threeYears,
      'description': 'Социализация и развитие в коллективе',
      'isPassed': now.isAfter(threeYears),
    });

    // 4 года - подготовка к школе
    final fourYears = _babyDob!.add(const Duration(days: 1460));
    milestones.add({
      'title': 'Подготовка к школе',
      'date': fourYears,
      'description': 'Развитие логики и подготовка к обучению',
      'isPassed': now.isAfter(fourYears),
    });

    // 5 лет - кружки и секции
    final fiveYears = _babyDob!.add(const Duration(days: 1825));
    milestones.add({
      'title': 'Кружки и секции',
      'date': fiveYears,
      'description': 'Выбор дополнительных занятий по интересам',
      'isPassed': now.isAfter(fiveYears),
    });

    // 6 лет - школа
    final sixYears = _babyDob!.add(const Duration(days: 2190));
    milestones.add({
      'title': 'Поступление в школу',
      'date': sixYears,
      'description': 'Начало школьного обучения',
      'isPassed': now.isAfter(sixYears),
    });

    // 7 лет - самостоятельность
    final sevenYears = _babyDob!.add(const Duration(days: 2555));
    milestones.add({
      'title': 'Развитие самостоятельности',
      'date': sevenYears,
      'description': 'Увеличение ответственности и самостоятельности',
      'isPassed': now.isAfter(sevenYears),
    });

    // 8 лет - хобби и интересы
    final eightYears = _babyDob!.add(const Duration(days: 2920));
    milestones.add({
      'title': 'Формирование хобби',
      'date': eightYears,
      'description': 'Развитие устойчивых интересов и увлечений',
      'isPassed': now.isAfter(eightYears),
    });

    // 9 лет - дружба и общение
    final nineYears = _babyDob!.add(const Duration(days: 3285));
    milestones.add({
      'title': 'Развитие дружбы',
      'date': nineYears,
      'description': 'Формирование крепких дружеских связей',
      'isPassed': now.isAfter(nineYears),
    });

    // 10 лет - переходный возраст
    final tenYears = _babyDob!.add(const Duration(days: 3650));
    milestones.add({
      'title': 'Подготовка к переходному возрасту',
      'date': tenYears,
      'description': 'Начало изменений в поведении и характере',
      'isPassed': now.isAfter(tenYears),
    });

    return milestones;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь малыша'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Блок с датой рождения
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Дата рождения',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            hintText: 'Выберите дату',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _selectDate,
                        ),
                      ),
                    ],
                  ),
                  if (_babyDob != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Возраст: ${_calculateAge()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Предстоящие события
            const Text(
              'Предстоящие события',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _babyDob == null
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Укажите дату рождения, чтобы увидеть события',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _getUpcomingMilestones().length,
                    itemBuilder: (context, index) {
                      final milestone = _getUpcomingMilestones()[index];
                      final isPassed = milestone['isPassed'] as bool;
                      final daysUntil = milestone['date'].difference(DateTime.now()).inDays;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isPassed ? Colors.grey[100] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPassed ? Colors.grey[300]! : Colors.blue[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPassed ? Icons.check_circle : Icons.schedule,
                              color: isPassed ? Colors.grey : Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    milestone['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isPassed ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    milestone['description'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isPassed ? Colors.grey : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isPassed 
                                        ? 'Прошло ${-daysUntil} дн назад'
                                        : 'Через $daysUntil дн',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isPassed ? Colors.grey : Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
}