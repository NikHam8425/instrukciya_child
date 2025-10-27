enum ContentKind { article, checklist, video }

class ContentItem {
  final String id;
  final String topicId;
  final String title;
  final ContentKind kind;
  final String body; // markdown/plain text for articles; JSON for checklist; url/asset for video
  final List<String> mediaAssets; // optional images/videos assets

  const ContentItem({
    required this.id,
    required this.topicId,
    required this.title,
    required this.kind,
    required this.body,
    this.mediaAssets = const [],
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
        id: json['id'] as String,
        topicId: json['topicId'] as String,
        title: json['title'] as String,
        kind: _kindFromString(json['kind'] as String? ?? 'article'),
        body: json['body'] as String? ?? '',
        mediaAssets: (json['mediaAssets'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'title': title,
        'kind': kind.name,
        'body': body,
        'mediaAssets': mediaAssets,
      };
}

ContentKind _kindFromString(String value) {
  switch (value) {
    case 'article':
      return ContentKind.article;
    case 'checklist':
      return ContentKind.checklist;
    case 'video':
      return ContentKind.video;
    default:
      return ContentKind.article;
  }
}


