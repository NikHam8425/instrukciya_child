import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/child_profile.dart';
import '../models/user_profile.dart';
import 'sections_screen.dart';
import 'main_shell.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // РЕБЁНОК
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();

  Gender _selectedGender = Gender.male;
  DateTime? _selectedBirthDate;

  // Списки опций (как у тебя были)
  final List<String> _specialNeedsOptions = const [
    'Нарушения речи',
    'Задержка развития',
    'Аутизм',
    'СДВГ',
    'ДЦП',
    'Нарушения слуха',
    'Нарушения зрения',
    'Другие особенности',
  ];
  final List<String> _allergiesOptions = const [
    'Молочные продукты',
    'Яйца',
    'Орехи',
    'Рыба',
    'Морепродукты',
    'Пшеница',
    'Соя',
    'Клубника',
    'Цитрусовые',
    'Другие аллергии',
  ];

  final List<String> _selectedSpecialNeeds = [];
  final List<String> _selectedAllergies = [];

  // РОДИТЕЛЬ
  final _parentNameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    _parentNameController.dispose();
    _parentEmailController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 18),
      lastDate: now,
      initialDate: _selectedBirthDate ?? DateTime(now.year - 1, now.month, now.day),
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  void _toggleItem(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final childProfile = ChildProfile(
      name: _nameController.text.trim(),
      gender: _selectedGender,
      birthDate: _selectedBirthDate ?? DateTime.now(),
      createdAt: DateTime.now(), // важно — требовалось конструктором
      height: double.tryParse(_heightController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0,
      allergies: List<String>.from(_selectedAllergies),
      specialNeeds: List<String>.from(_selectedSpecialNeeds),
      notes: _notesController.text.trim(),
    );
    await childProfile.save();

    final parent = UserProfile(
      name: _parentNameController.text.trim(),
      email: _parentEmailController.text.trim().isEmpty
          ? null
          : _parentEmailController.text.trim(),
      phone: _parentPhoneController.text.trim().isEmpty
          ? null
          : _parentPhoneController.text.trim(),
    );
    await parent.save();

    if (!mounted) return;

    // Переход на экран развития
    try {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (_) {
      // fallback, если MainShell другое имя/его нет
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Данные ребёнка =====
                const Text('Данные ребёнка',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                // Имя
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Имя ребёнка *'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Введите имя ребёнка' : null,
                ),
                const SizedBox(height: 12),
                // Пол
                Row(
                  children: [
                    const Text('Пол:'),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('М'),
                      selected: _selectedGender == Gender.male,
                      onSelected: (_) => setState(() => _selectedGender = Gender.male),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Ж'),
                      selected: _selectedGender == Gender.female,
                      onSelected: (_) => setState(() => _selectedGender = Gender.female),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Дата рождения
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Дата рождения: ${(_selectedBirthDate ?? DateTime.now()).toLocal().toString().split(' ').first}',
                      ),
                    ),
                    TextButton(
                      onPressed: _pickBirthDate,
                      child: const Text('Выбрать'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Вес
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: const InputDecoration(labelText: 'Вес (кг, необязательно)'),
                ),
                const SizedBox(height: 12),
                // Рост
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: const InputDecoration(labelText: 'Рост (см, необязательно)'),
                ),
                const SizedBox(height: 16),

                // Особые потребности
                ExpansionTile(
                  title: const Text('Особые потребности'),
                  children: _specialNeedsOptions
                      .map(
                        (e) => CheckboxListTile(
                          value: _selectedSpecialNeeds.contains(e),
                          onChanged: (_) => _toggleItem(_selectedSpecialNeeds, e),
                          title: Text(e),
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),

                // Аллергии
                ExpansionTile(
                  title: const Text('Аллергии'),
                  children: _allergiesOptions
                      .map(
                        (e) => CheckboxListTile(
                          value: _selectedAllergies.contains(e),
                          onChanged: (_) => _toggleItem(_selectedAllergies, e),
                          title: Text(e),
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),

                // Комментарий
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Комментарий / заметки (необязательно)',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 32),

                // ===== Данные родителя =====
                const Text('Данные родителя',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(labelText: 'Имя родителя *'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Укажите имя родителя' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _parentEmailController,
                  decoration: const InputDecoration(labelText: 'Email (необязательно)'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _parentPhoneController,
                  decoration: const InputDecoration(labelText: 'Телефон (необязательно)'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                  ],
                ),

                const SizedBox(height: 28),
                Center(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
