import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String? email;
  final String? phone;
  final String? avatarPath;
  final DateTime createdAt;

  UserProfile({
    required this.name,
    this.email,
    this.phone,
    this.avatarPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'avatarPath': avatarPath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      avatarPath: map['avatarPath'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String json) =>
      UserProfile.fromMap(jsonDecode(json) as Map<String, dynamic>);

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parentProfile', toJson());
  }

  static Future<UserProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('parentProfile');
    if (jsonStr == null) return null;
    try {
      return UserProfile.fromJson(jsonStr);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('parentProfile');
  }
}
