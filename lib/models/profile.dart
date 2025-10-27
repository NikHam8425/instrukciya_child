class UserProfile {
  final String parentName;
  final String? childName;
  final String? childGender; // optional
  final int? childAgeMonths; // store granular age in months for 0-8y range
  final String? emailOrPhone;

  final Set<String> completedContentIds;
  final Set<String> favoriteContentIds;

  const UserProfile({
    required this.parentName,
    this.childName,
    this.childGender,
    this.childAgeMonths,
    this.emailOrPhone,
    this.completedContentIds = const {},
    this.favoriteContentIds = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        parentName: json['parentName'] as String? ?? '',
        childName: json['childName'] as String?,
        childGender: json['childGender'] as String?,
        childAgeMonths: json['childAgeMonths'] as int?,
        emailOrPhone: json['emailOrPhone'] as String?,
        completedContentIds:
            Set<String>.from((json['completedContentIds'] as List?)?.map((e) => e.toString()) ?? const <String>[]),
        favoriteContentIds:
            Set<String>.from((json['favoriteContentIds'] as List?)?.map((e) => e.toString()) ?? const <String>[]),
      );

  Map<String, dynamic> toJson() => {
        'parentName': parentName,
        'childName': childName,
        'childGender': childGender,
        'childAgeMonths': childAgeMonths,
        'emailOrPhone': emailOrPhone,
        'completedContentIds': completedContentIds.toList(),
        'favoriteContentIds': favoriteContentIds.toList(),
      };
}


