import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum Gender { male, female }

class ChildProfile {
  final String name;
  final Gender gender;
  final DateTime birthDate;
  final double weight; // в кг
  final double height; // в см
  final List<String> specialNeeds;
  final List<String> allergies;
  final String notes;
  final DateTime createdAt;

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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender.name,
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
    return ChildProfile(
      name: json['name'] as String,
      gender: Gender.values.firstWhere((g) => g.name == json['gender']),
      birthDate: DateTime.parse(json['birthDate'] as String),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      specialNeeds: List<String>.from(json['specialNeeds'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Вычисляем возраст в месяцах
  int get ageInMonths {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    return (difference.inDays / 30.44).floor();
  }

  // Вычисляем возраст в годах
  int get ageInYears {
    return (ageInMonths / 12).floor();
  }

  // Вычисляем ИМТ
  double get bmi {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Получаем рекомендации на основе данных
  List<String> get recommendations {
    final recommendations = <String>[];
    
    // Рекомендации по возрасту
    if (ageInMonths < 6) {
      recommendations.add('Исключительно грудное вскармливание или смесь');
      recommendations.add('Регулярные осмотры педиатра');
    } else if (ageInMonths < 12) {
      recommendations.add('Введение прикорма с 6 месяцев');
      recommendations.add('Развитие мелкой моторики');
    } else if (ageInYears < 3) {
      recommendations.add('Активное развитие речи');
      recommendations.add('Приучение к горшку');
    } else if (ageInYears < 6) {
      recommendations.add('Подготовка к детскому саду');
      recommendations.add('Развитие социальных навыков');
    } else {
      recommendations.add('Подготовка к школе');
      recommendations.add('Развитие самостоятельности');
    }

    // Рекомендации по ИМТ
    if (bmi < 14) {
      recommendations.add('Консультация с педиатром по весу');
    } else if (bmi > 20) {
      recommendations.add('Контроль питания и физической активности');
    }

    // Рекомендации по особым потребностям
    if (specialNeeds.isNotEmpty) {
      recommendations.add('Индивидуальный подход к развитию');
      recommendations.add('Консультации со специалистами');
    }

    // Рекомендации по аллергиям
    if (allergies.isNotEmpty) {
      recommendations.add('Внимательно следите за рационом');
      recommendations.add('Имейте при себе антигистаминные препараты');
    }

    return recommendations;
  }

  // Сохранение в SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('childProfile', jsonEncode(toJson()));
  }

  // Загрузка из SharedPreferences
  static Future<ChildProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString('childProfile');
    
    if (profileString != null) {
      try {
        final profileJson = jsonDecode(profileString) as Map<String, dynamic>;
        return ChildProfile.fromJson(profileJson);
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  // Проверка, есть ли сохранённый профиль
  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('childProfile');
  }
}

