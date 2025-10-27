import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onDone});

  final void Function(UserProfile profile)? onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _parentCtrl = TextEditingController();
  final _childCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  String? _gender;
  int? _ageMonths;
  bool _policyAccepted = false;

  @override
  void dispose() {
    _parentCtrl.dispose();
    _childCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', profile.toJson().toString());
  }

  void _submit() async {
    if (!_policyAccepted) return;
    if (_formKey.currentState?.validate() != true) return;
    final profile = UserProfile(
      parentName: _parentCtrl.text.trim(),
      childName: _childCtrl.text.trim().isEmpty ? null : _childCtrl.text.trim(),
      childGender: _gender,
      childAgeMonths: _ageMonths,
      emailOrPhone: _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
    );
    await _saveProfile(profile);
    widget.onDone?.call(profile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('О вас и ребёнке')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _parentCtrl,
                  decoration: const InputDecoration(labelText: 'ФИО родителя'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите ФИО' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _childCtrl,
                  decoration: const InputDecoration(labelText: 'Имя ребёнка (необязательно)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Пол (по желанию)'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Мальчик')),
                    DropdownMenuItem(value: 'female', child: Text('Девочка')),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Возраст в месяцах'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final parsed = int.tryParse(v);
                    setState(() => _ageMonths = parsed);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactCtrl,
                  decoration: const InputDecoration(labelText: 'Email или телефон'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _policyAccepted,
                      onChanged: (v) => setState(() => _policyAccepted = v ?? false),
                    ),
                    const Expanded(child: Text('Согласен(на) с политикой конфиденциальности')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _policyAccepted ? _submit : null,
                        child: const Text('Продолжить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


