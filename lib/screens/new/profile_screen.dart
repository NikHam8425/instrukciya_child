import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../state/profile_state.dart';
import '../../models/user_profile.dart';
import '../../models/child_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Родитель
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _avatarPath;

  // Ребёнок
  final _childNameCtrl = TextEditingController();
  DateTime? _childBirthdate;
  final _childWeightCtrl = TextEditingController(); // кг
  final _childHeightCtrl = TextEditingController(); // см
  final _childAllergiesCtrl = TextEditingController(); // через запятую
  final _childNeedsCtrl = TextEditingController(); // через запятую
  final _childNotesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileState>();
    // Родитель
    _avatarPath = state.user.avatarPath;
    _nameCtrl.text = state.user.name;
    _emailCtrl.text = state.user.email ?? '';
    _phoneCtrl.text = state.user.phone ?? '';
    // Ребёнок
    final child = state.child;
    if (child != null) {
      _childNameCtrl.text = child.name;
      _childBirthdate = child.birthDate;
      _childWeightCtrl.text = (child.weight == 0 ? '' : child.weight.toString());
      _childHeightCtrl.text = (child.height == 0 ? '' : child.height.toString());
      _childAllergiesCtrl.text = child.allergies.join(', ');
      _childNeedsCtrl.text = child.specialNeeds.join(', ');
      _childNotesCtrl.text = child.notes;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _childNameCtrl.dispose();
    _childWeightCtrl.dispose();
    _childHeightCtrl.dispose();
    _childAllergiesCtrl.dispose();
    _childNeedsCtrl.dispose();
    _childNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (file != null && mounted) {
      setState(() => _avatarPath = file.path);
    }
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final initial = _childBirthdate ?? DateTime(now.year - 5, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (date != null) setState(() => _childBirthdate = date);
  }

  double _parseDouble(String s) => double.tryParse(s.replaceAll(',', '.').trim()) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<ProfileState>();

    // user
    final user = UserProfile(
      avatarPath: _avatarPath,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      childName: _childNameCtrl.text.trim().isEmpty ? null : _childNameCtrl.text.trim(),
      childBirthdate: _childBirthdate,
    );

    // child (необязателен)
    ChildProfile? child;
    if (_childNameCtrl.text.trim().isNotEmpty && _childBirthdate != null) {
      child = ChildProfile(
        name: _childNameCtrl.text.trim(),
        gender: Gender.male, // при желании добавим переключатель пола позже
        birthDate: _childBirthdate!,
        weight: _parseDouble(_childWeightCtrl.text),
        height: _parseDouble(_childHeightCtrl.text),
        allergies: _childAllergiesCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        specialNeeds: _childNeedsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        notes: _childNotesCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
    }

    await state.updateUser(user);
    await state.updateChild(child);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Профиль сохранён')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 12);
    final profile = context.watch<ProfileState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватар
              Center(
                child: InkWell(
                  onTap: _pickAvatar,
                  borderRadius: BorderRadius.circular(60),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: (_avatarPath != null && File(_avatarPath!).existsSync())
                        ? FileImage(File(_avatarPath!))
                        : null,
                    child: (_avatarPath == null)
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Родитель', style: TextStyle(fontWeight: FontWeight.w600)),
              spacing,
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Имя и фамилия *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Укажите имя' : null,
              ),
              spacing,
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              spacing,
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),
              const Text('Ребёнок (необязательно)', style: TextStyle(fontWeight: FontWeight.w600)),
              spacing,
              TextFormField(
                controller: _childNameCtrl,
                decoration: const InputDecoration(labelText: 'Имя ребёнка'),
              ),
              spacing,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickBirthdate,
                      icon: const Icon(Icons.cake_outlined),
                      label: Text(
                        _childBirthdate == null
                            ? 'Дата рождения'
                            : '${_childBirthdate!.day.toString().padLeft(2, '0')}.'
                              '${_childBirthdate!.month.toString().padLeft(2, '0')}.'
                              '${_childBirthdate!.year}',
                      ),
                    ),
                  ),
                ],
              ),
              spacing,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _childWeightCtrl,
                      decoration: const InputDecoration(labelText: 'Вес (кг)'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _childHeightCtrl,
                      decoration: const InputDecoration(labelText: 'Рост (см)'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              spacing,
              TextFormField(
                controller: _childAllergiesCtrl,
                decoration: const InputDecoration(labelText: 'Аллергии (через запятую)'),
              ),
              spacing,
              TextFormField(
                controller: _childNeedsCtrl,
                decoration: const InputDecoration(labelText: 'Особые потребности (через запятую)'),
              ),
              spacing,
              TextFormField(
                controller: _childNotesCtrl,
                decoration: const InputDecoration(labelText: 'Заметки'),
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить'),
              ),

              const SizedBox(height: 12),
              if (profile.child != null)
                Text('ИМТ ребёнка: ${profile.child!.bmi}  |  Возраст: ${profile.child!.ageInYears} лет'),
            ],
          ),
        ),
      ),
    );
  }
}
