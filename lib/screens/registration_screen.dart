import '../../models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/child_profile.dart';
import 'package:provider/provider.dart';
import '../state/profile_state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();
  
  Gender _selectedGender = Gender.male;
  DateTime? _selectedBirthDate;
  final List<String> _selectedSpecialNeeds = [];
  final List<String> _selectedAllergies = [];

  final List<String> _specialNeedsOptions = [
    'Нарушения речи',
    'Задержка развития',
    'Аутизм',
    'СДВГ',
    'ДЦП',
    'Нарушения слуха',
    'Нарушения зрения',
    'Другие особенности',
  ];

  final List<String> _allergiesOptions = [
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

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2014), // 10 лет назад
      lastDate: DateTime.now(),
      locale: const Locale('ru', 'RU'),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedBirthDate = selectedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _toggleSpecialNeed(String need) {
    setState(() {
      if (_selectedSpecialNeeds.contains(need)) {
        _selectedSpecialNeeds.remove(need);
      } else {
        _selectedSpecialNeeds.add(need);
      }
    });
  }

  void _toggleAllergy(String allergy) {
    setState(() {
      if (_selectedAllergies.contains(allergy)) {
        _selectedAllergies.remove(allergy);
      } else {
        _selectedAllergies.add(allergy);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите дату рождения')),
      );
      return;
    }

    try {
      final profile = ChildProfile(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        birthDate: _selectedBirthDate!,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        specialNeeds: _selectedSpecialNeeds,
        allergies: _selectedAllergies,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await context.read<ProfileState>().updateChild(profile);

      await context.read<ProfileState>().updateUser(
        UserProfile(
          name: 'Имя родителя',
          email: 'почта',
          phone: '+7 900 000-00-00',
          avatarPath: null,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно сохранён')),
        );
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Основная информация
              _buildSection(
                title: 'Основная информация',
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя ребёнка',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите имя ребёнка';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Пол
                  const Text('Пол', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<Gender>(
                          title: const Text('Мальчик'),
                          value: Gender.male,
                          groupValue: _selectedGender,
                          onChanged: (value) => setState(() => _selectedGender = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<Gender>(
                          title: const Text('Девочка'),
                          value: Gender.female,
                          groupValue: _selectedGender,
                          onChanged: (value) => setState(() => _selectedGender = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Дата рождения
                  InkWell(
                    onTap: _selectBirthDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            _selectedBirthDate != null 
                                ? _formatDate(_selectedBirthDate!)
                                : 'Выберите дату рождения',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedBirthDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Физические параметры
              _buildSection(
                title: 'Физические параметры',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Вес (кг)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.monitor_weight),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите вес';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0 || weight > 100) {
                              return 'Введите корректный вес';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Рост (см)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.height),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите рост';
                            }
                            final height = double.tryParse(value);
                            if (height == null || height <= 0 || height > 200) {
                              return 'Введите корректный рост';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Особые потребности
              _buildSection(
                title: 'Особые потребности (необязательно)',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _specialNeedsOptions.map((need) {
                      final isSelected = _selectedSpecialNeeds.contains(need);
                      return FilterChip(
                        label: Text(need),
                        selected: isSelected,
                        onSelected: (_) => _toggleSpecialNeed(need),
                        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Аллергии
              _buildSection(
                title: 'Аллергии (необязательно)',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allergiesOptions.map((allergy) {
                      final isSelected = _selectedAllergies.contains(allergy);
                      return FilterChip(
                        label: Text(allergy),
                        selected: isSelected,
                        onSelected: (_) => _toggleAllergy(allergy),
                        selectedColor: Colors.red.withValues(alpha: 0.2),
                        checkmarkColor: Colors.red,
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Дополнительные заметки
              _buildSection(
                title: 'Дополнительные заметки (необязательно)',
                children: [
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Заметки о ребёнке',
                      border: OutlineInputBorder(),
                      hintText: 'Любая дополнительная информация...',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 200), // Больше места для тестирования скролла
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Сохранить профиль',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
