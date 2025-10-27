class Period {
  final String id; // e.g., prenatal, age_0_1, age_1_3, age_3_5, age_6_8
  final String title;
  final String emoji;
  final String description;

  const Period({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'description': description,
      };
}


