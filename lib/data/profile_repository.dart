import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/child_profile.dart';

class ProfileRepository {
  static const _key = 'profile_all';

  Future<void> saveAll({
    required UserProfile user,
    required ChildProfile? child,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'user': user.toJson(),
      'child': child?.toJson(),
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<(UserProfile, ChildProfile?)?> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      final user = UserProfile.fromJson((map['user'] as Map).cast<String, dynamic>());
      final childMap = map['child'] as Map<String, dynamic>?;
      final child = childMap == null ? null : ChildProfile.fromJson(childMap);
      return (user, child);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
