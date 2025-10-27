import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  static const String _dobKey = 'baby_dob';
  static const String _progressKey = 'progress_checked_steps';
  static const String _familyFeedKey = 'family_feed';

  Future<DateTime?> loadBabyDob() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_dobKey);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  Future<void> saveBabyDob(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dobKey, date.toIso8601String());
  }

  Future<Set<int>> loadCheckedSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_progressKey) ?? const [];
    return list.map(int.parse).toSet();
  }

  Future<void> saveCheckedSteps(Set<int> checked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_progressKey, checked.map((e) => e.toString()).toList());
  }

  Future<List<String>> loadFamilyFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_familyFeedKey);
    if (str == null) return const [];
    final List<dynamic> data = jsonDecode(str) as List<dynamic>;
    return data.cast<String>();
  }

  Future<void> addFamilyFeedItem(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadFamilyFeed();
    final updated = [text, ...current];
    await prefs.setString(_familyFeedKey, jsonEncode(updated));
  }
}


