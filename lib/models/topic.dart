class TopicItem {
  final String id;
  final String title;
  final String summary;
  final String? imageAsset;
  final List<String> tags; // e.g., video, checklist, article

  const TopicItem({
    required this.id,
    required this.title,
    required this.summary,
    this.imageAsset,
    this.tags = const [],
  });

  factory TopicItem.fromJson(Map<String, dynamic> json) => TopicItem(
        id: json['id'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String? ?? '',
        imageAsset: json['imageAsset'] as String?,
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'imageAsset': imageAsset,
        'tags': tags,
      };
}


