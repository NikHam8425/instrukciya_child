import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

enum Gender { male, female }

class ChildProfile {
  final String name;
  final Gender gender;
  final DateTime birthDate;
  /// Вес в кг
  final double weight;
  /// Рост в см
  final double height;
  final List<String> specialNeeds;
  final List<String> allergies;
  final String notes;
  final DateTime createdAt;

  static const _prefsKey = 'childProfile'; // общий префикс-ключ для безопасного хранения

  const ChildProfile({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.weight,
    required this.height,
    this.specialNeeds = const [],
    this.allergies = const [],
    this.notes = '',
    required this.createdAt,
  });

  ChildProfile copyWith({
    String? name,
    Gender? gender,
    DateTime? birthDate,
    double? weight,
    double? height,
    List<String>? specialNeeds,
    List<String>? allergies,
    String? notes,
    DateTime? createdAt,
  }) {
    return ChildProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
    }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender.name, // male/female
      'birthDate': birthDate.toIso8601String(),
      'weight': weight,
      'height': height,
      'specialNeeds': specialNeeds,
      'allergies': allergies,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    // Безопасный парсинг
    final rawGender = (json['gender'] as String?) ?? 'male';
    final parsedGender = Gender.values.firstWhere(
      (g) => g.name == rawGender,
      orElse: () => Gender.male,
    );

    DateTime _safeParseDate(String? s, {DateTime? fallback}) {
      final d = s == null ? null : DateTime.tryParse(s);
      return d ?? (fallback ?? DateTime.now());
    }

    double _toDouble(dynamic v, {double fallback = 0}) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    List<String> _stringList(dynamic v) {
      if (v is List) {
        return v.whereType<String>().toList();
      }
      return const [];
    }

    return ChildProfile(
      name: (json['name'] as String?)?.trim() ?? '',
      gender: parsedGender,
      birthDate: _safeParseDate(json['birthDate'] as String?),
      weight: _toDouble(json['weight'], fallback: 0),
      height: _toDouble(json['height'], fallback: 0),
      specialNeeds: _stringList(json['specialNeeds']),
      allergies: _stringList(json['allergies']),
      notes: (json['notes'] as String?) ?? '',
      createdAt: _safeParseDate(json['createdAt'] as String?, fallback: DateTime.now()),
    );
  }

  /// Возраст в месяцах по календарю (точнее, чем делить на 30.44)
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months -= 1;
    return months.clamp(0, 1200); // защита от отрицательных/чрезмерных значений
  }

  /// Возраст в годах (целые)
  int get ageInYears => (ageInMonths / 12).floor();

  /// ИМТ с защитой от деления на ноль
  double get bmi {
    final h = height / 100.0;
    if (h <= 0) return 0;
    final value = weight / (h * h);
    if (value.isNaN || value.isInfinite) return 0;
    return double.parse(value.toStringAsFixed(2));
  }

  /// Рекомендации (уникальные и по делу)
  List<String> get recommendations {
    final set = <String>{};

    // По возрасту
    if (ageInMonths < 6) {
      set.add('Исключительно грудное вскармливание или смесь');
      set.add('Регулярные осмотры педиатра');
    } else if (ageInMonths < 12) {
      set.add('Введение прикорма с 6 месяцев');
      set.add('Развитие мелкой моторики');
    } else if (ageInYears < 3) {
      set.add('Активное развитие речи');
      set.add('Приучение к горшку');
    } else if (ageInYears < 6) {
      set.add('Подготовка к детскому саду');
      set.add('Развитие социальных навыков');
    } else {
      set.add('Подготовка к школе');
      set.add('Развитие самостоятельности');
    }

    // По ИМТ (очень условно; при сомнениях — к врачу)
    if (bmi > 0 && bmi < 14) {
      set.add('Проконсультируйтесь с педиатром по вопросу массы тела');
    } else if (bmi > 20) {
      set.add('Сбалансированное питание и регулярная физическая активность');
    }

    if (specialNeeds.isNotEmpty) {
      set.add('Индивидуальный план развития совместно со специалистами');
    }
    if (allergies.isNotEmpty) {
      set.add('Контролируйте рацион и держите антигистаминные по рекомендации врача');
    }

    return set.toList(growable: false);
  }

  // --- Persistence ---

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toJson()));
  }

  static Future<ChildProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_prefsKey);
    if (s == null) return null;
    try {
      final jsonMap = jsonDecode(s) as Map<String, dynamic>;
      return ChildProfile.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_prefsKey);
  }

  // Удобно для тестов/сброса
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  // Сравнение и хэш (удобно для Provider/Bloc)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildProfile &&
        other.name == name &&
        other.gender == gender &&
        other.birthDate == birthDate &&
        other.weight == weight &&
        other.height == height &&
        _listEquals(other.specialNeeds, specialNeeds) &&
        _listEquals(other.allergies, allergies) &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      gender,
      birthDate,
      weight,
      height,
      Object.hashAll(specialNeeds),
      Object.hashAll(allergies),
      notes,
      createdAt,
    );
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
