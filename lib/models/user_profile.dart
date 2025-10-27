class UserProfile {
  final String? avatarPath; // локальный путь к файлу
  final String name;
  final String? email;
  final String? phone;

  // Данные ребёнка (минимально)
  final String? childName;
  final DateTime? childBirthdate;

  const UserProfile({
    this.avatarPath,
    required this.name,
    this.email,
    this.phone,
    this.childName,
    this.childBirthdate,
  });

  UserProfile copyWith({
    String? avatarPath,
    String? name,
    String? email,
    String? phone,
    String? childName,
    DateTime? childBirthdate,
  }) {
    return UserProfile(
      avatarPath: avatarPath ?? this.avatarPath,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      childName: childName ?? this.childName,
      childBirthdate: childBirthdate ?? this.childBirthdate,
    );
  }

  Map<String, dynamic> toJson() => {
        'avatarPath': avatarPath,
        'name': name,
        'email': email,
        'phone': phone,
        'childName': childName,
        'childBirthdate': childBirthdate?.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      avatarPath: json['avatarPath'] as String?,
      name: (json['name'] as String?) ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      childName: json['childName'] as String?,
      childBirthdate: (json['childBirthdate'] as String?) != null
          ? DateTime.tryParse(json['childBirthdate'] as String)
          : null,
    );
  }

  static const empty = UserProfile(name: '');
}
