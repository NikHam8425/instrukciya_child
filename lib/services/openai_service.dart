import 'dart:async';

import '../models/child_profile.dart';

/// Конфиг для ключа OpenAI (если когда‑нибудь захочешь подключить реальный API).
class OpenAIConfig {
  static const apiKey = String.fromEnvironment('OPENAI_API_KEY');
}

/// Простая заглушка OpenAI‑ассистента, чтобы приложение стабильно работало
/// даже без реального ключа и сети.
///
/// Сейчас она просто генерирует осмысленный текст на основе вопроса
/// и данных о ребёнке. При желании сюда можно потом воткнуть реальный HTTP‑клиент.
class OpenAIService {
  Future<String> askWithChildProfile({
    required String userMessage,
    required ChildProfile? child,
  }) async {
    // Лёгкая имитация задержки сети
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final buffer = StringBuffer();

    buffer.writeln('Спасибо за вопрос! Вот базовые рекомендации:');
    buffer.writeln();

    if (child != null) {
      buffer.writeln(
        'Мы учитываем профиль вашего ребёнка: '
        '${child.name.isNotEmpty ? child.name : 'имя не указано'}, '
        '${child.gender == Gender.male ? 'мальчик' : 'девочка'}, '
        'возраст: примерно ${_formatAge(child.birthDate)}.',
      );
      buffer.writeln();
    }

    buffer.writeln(
      '1. Постарайтесь сохранять спокойствие и наблюдать за реакцией ребёнка. '
      'Каждый малыш индивидуален, и многое зависит от общего самочувствия.',
    );
    buffer.writeln(
      '2. Если вас что‑то беспокоит (поведение, сон, аппетит, температура), '
      'лучше дополнительно проконсультироваться с педиатром.',
    );
    buffer.writeln(
      '3. Важно следить за режимом дня, достаточным сном и мягким эмоциональным '
      'контактом: объятия, спокойный голос, совместные игры.',
    );
    buffer.writeln();
    buffer.writeln(
      'Ваш вопрос: "$userMessage". На основе его формулировки можно уточнить '
      'симптомы, длительность проблемы и сопутствующие факторы, '
      'чтобы дать более точную рекомендацию.',
    );

    buffer.writeln();
    buffer.writeln(
      '⚠️ Важно: ответы внутри приложения не заменяют консультацию врача. '
      'При острых симптомах (высокая температура, вялость, одышка, сыпь и т.п.) '
      'обратитесь за неотложной медицинской помощью.',
    );

    return buffer.toString();
  }

  String _formatAge(DateTime birthDate) {
    final now = DateTime.now();
    final diff = now.difference(birthDate);
    final days = diff.inDays;

    if (days < 30) return '$days дней';
    if (days < 365) {
      final months = (days / 30).floor();
      return '$months мес';
    }
    final years = (days / 365).floor();
    final months = ((days % 365) / 30).floor();
    if (months <= 0) return '$years лет';
    return '$years г $months мес';
  }
}

