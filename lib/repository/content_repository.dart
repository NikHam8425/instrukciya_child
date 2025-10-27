import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/content_item.dart';
import '../models/period.dart';
import '../models/topic.dart';

abstract class ContentRepository {
  Future<List<Period>> loadPeriods();
  Future<List<TopicItem>> loadTopics(String periodId);
  Future<List<ContentItem>> loadContentByTopic(String topicId);
}

class AssetContentRepository implements ContentRepository {
  static const String basePath = 'assets/content/';

  @override
  Future<List<Period>> loadPeriods() async {
    final String jsonStr = await rootBundle.loadString('${basePath}periods.json');
    final List list = json.decode(jsonStr) as List;
    return list.map((e) => Period.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TopicItem>> loadTopics(String periodId) async {
    final String jsonStr = await rootBundle.loadString('${basePath}topics_$periodId.json');
    final List list = json.decode(jsonStr) as List;
    return list.map((e) => TopicItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ContentItem>> loadContentByTopic(String topicId) async {
    final String jsonStr = await rootBundle.loadString('${basePath}content_$topicId.json');
    final List list = json.decode(jsonStr) as List;
    return list.map((e) => ContentItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}


