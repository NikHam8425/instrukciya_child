import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/payment_service.dart';
import 'package:instrukciya_child/screens/ages/pregnancy_screen.dart';
import 'package:instrukciya_child/screens/ages/age_0_1_screen.dart';
import 'package:instrukciya_child/screens/ages/age_1_3_screen.dart';
import 'package:instrukciya_child/screens/ages/age_3_5_screen.dart';
import 'package:instrukciya_child/screens/ages/age_6_8_screen.dart';
import 'package:instrukciya_child/screens/ages/age_9_10_screen.dart';
import 'package:instrukciya_child/screens/ages/age_11_13_screen.dart';
import 'package:instrukciya_child/screens/ages/age_14_17_screen.dart';

// Helper function для получения информации о подписке
Future<Map<String, dynamic>> _getSubscriptionInfo() async {
  final paymentService = PaymentService();
  final isPremium = await paymentService.isPremium();
  final remaining = await paymentService.getRemainingFreeActions();
  
  return {
    'isPremium': isPremium,
    'remaining': remaining,
  };
}

class SectionsScreen extends StatelessWidget {
  const SectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = const [
      ('prenatal', 'Подготовка к родам', '👶'),
      ('age_0_1', '0–1 год', '🍼'),
      ('age_1_3', '1–3 года', '🚼'),
      ('age_3_5', '3–5 лет', '🎒'),
      ('age_6_8', '6–8 лет', '🧠'),
      ('age_9_10', '9–10 лет', '💡'),
      ('age_11_13', '11–13 лет', '⚡️'),
      ('age_14_17', '14–17 лет', '🔥'),
    ];

    void openScreen(BuildContext context, String id) {
      Widget screen;
      switch (id) {
        case 'prenatal':
          screen = const PregnancyScreen();
          break;
        case 'age_0_1':
          screen = const Age0to1Screen();
          break;
        case 'age_1_3':
          screen = const Age1to3Screen();
          break;
        case 'age_3_5':
          screen = const Age3to5Screen();
          break;
        case 'age_6_8':
          screen = const Age6to8Screen();
          break;
        case 'age_9_10':
          screen = const Age9to10Screen();
          break;
        case 'age_11_13':
          screen = const Age11to13Screen();
          break;
        case 'age_14_17':
          screen = const Age14to17Screen();
          break;
        default:
          screen = const Scaffold(
            body: Center(child: Text('Раздел в разработке')),
          );
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мамин путь'),
        actions: [
          // Счетчик бесплатных обращений
          FutureBuilder<Map<String, dynamic>>(
            future: _getSubscriptionInfo(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              
              final data = snapshot.data!;
              final isPremium = data['isPremium'] as bool;
              final remaining = data['remaining'] as int;
              
              if (isPremium) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: remaining > 0 ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: remaining > 0 ? Colors.green : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          remaining > 0 ? Icons.check_circle : Icons.lock,
                          size: 16,
                          color: remaining > 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$remaining/5',
                          style: TextStyle(
                            color: remaining > 0 ? Colors.green.shade900 : Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _RecommendationsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.recommend, size: 18),
              label: const Text('Советы'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) {
          final it = items[i];
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.white,
            leading: Text(it.$3, style: theme.textTheme.headlineSmall),
            title: Text(it.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openScreen(context, it.$1),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
    );
  }
}

// ===== РЕКОМЕНДАЦИИ =====

enum PlaceType { hospital, clinic, developmentCenter, other }

class _Recommendation {
  final String id;
  final String name;
  final String address;
  final PlaceType type;
  final double rating;
  final String review;
  final String authorName;
  final DateTime date;
  final String? phone;

  const _Recommendation({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.rating,
    required this.review,
    required this.authorName,
    required this.date,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'type': type.name,
        'rating': rating,
        'review': review,
        'authorName': authorName,
        'date': date.toIso8601String(),
        'phone': phone,
      };

  factory _Recommendation.fromJson(Map<String, dynamic> json) =>
      _Recommendation(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        type: PlaceType.values.firstWhere((e) => e.name == json['type']),
        rating: (json['rating'] as num).toDouble(),
        review: json['review'] as String,
        authorName: json['authorName'] as String,
        date: DateTime.parse(json['date'] as String),
        phone: json['phone'] as String?,
      );

  String get typeLabel {
    switch (type) {
      case PlaceType.hospital:
        return 'Роддом';
      case PlaceType.clinic:
        return 'Поликлиника';
      case PlaceType.developmentCenter:
        return 'Развивающий центр';
      case PlaceType.other:
        return 'Другое';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case PlaceType.hospital:
        return Icons.local_hospital;
      case PlaceType.clinic:
        return Icons.medical_services;
      case PlaceType.developmentCenter:
        return Icons.school;
      case PlaceType.other:
        return Icons.place;
    }
  }
}

class _RecommendationsScreen extends StatefulWidget {
  const _RecommendationsScreen();

  @override
  State<_RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<_RecommendationsScreen> {
  List<_Recommendation> _recommendations = [];
  bool _loading = true;
  PlaceType? _filterType;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final recsString = prefs.getString('recommendations');

    if (recsString != null) {
      try {
        final jsonList = jsonDecode(recsString) as List;
        setState(() {
          _recommendations = jsonList
              .map((json) =>
                  _Recommendation.fromJson(json as Map<String, dynamic>))
              .toList();
          _loading = false;
        });
      } catch (e) {
        setState(() => _loading = false);
      }
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _recommendations.map((e) => e.toJson()).toList();
    await prefs.setString('recommendations', jsonEncode(jsonList));
  }

  Future<void> _addRecommendation(_Recommendation rec) async {
    setState(() => _recommendations.insert(0, rec));
    await _saveRecommendations();
  }

  Future<void> _deleteRecommendation(String id) async {
    setState(() => _recommendations.removeWhere((e) => e.id == id));
    await _saveRecommendations();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddRecommendationDialog(
        onAdd: (rec) {
          _addRecommendation(rec);
          Navigator.pop(context);
        },
      ),
    );
  }

  List<_Recommendation> get _filteredRecommendations {
    if (_filterType == null) return _recommendations;
    return _recommendations.where((r) => r.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рекомендации'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все'),
                  selected: _filterType == null,
                  onSelected: (selected) => setState(() => _filterType = null),
                ),
                const SizedBox(width: 8),
                ...PlaceType.values.map((type) {
                  final rec = _Recommendation(
                    id: '',
                    name: '',
                    address: '',
                    type: type,
                    rating: 0,
                    review: '',
                    authorName: '',
                    date: DateTime.now(),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(rec.typeLabel),
                      selected: _filterType == type,
                      onSelected: (selected) {
                        setState(() => _filterType = selected ? type : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecommendations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.rate_review,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _filterType == null
                                  ? 'Пока нет рекомендаций'
                                  : 'Нет рекомендаций в этой категории',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: _showAddDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Добавить'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRecommendations.length,
                        itemBuilder: (context, index) {
                          final rec = _filteredRecommendations[index];
                          return _RecommendationCard(
                            recommendation: rec,
                            onDelete: () => _deleteRecommendation(rec.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final _Recommendation recommendation;
  final VoidCallback onDelete;

  const _RecommendationCard({
    required this.recommendation,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(recommendation.typeIcon, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        recommendation.typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Удалить?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Отмена'),
                          ),
                          FilledButton(
                            onPressed: () {
                              onDelete();
                              Navigator.pop(context);
                            },
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) {
                  return Icon(
                    i < recommendation.rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(recommendation.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(recommendation.address,
                      style: TextStyle(color: Colors.grey[700])),
                ),
              ],
            ),
            if (recommendation.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(recommendation.phone!,
                      style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(recommendation.review, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(recommendation.authorName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRecommendationDialog extends StatefulWidget {
  final Function(_Recommendation) onAdd;

  const _AddRecommendationDialog({required this.onAdd});

  @override
  State<_AddRecommendationDialog> createState() =>
      _AddRecommendationDialogState();
}

class _AddRecommendationDialogState extends State<_AddRecommendationDialog> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _reviewController = TextEditingController();
  final _authorController = TextEditingController();
  final _phoneController = TextEditingController();
  PlaceType _selectedType = PlaceType.hospital;
  double _rating = 5.0;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _reviewController.dispose();
    _authorController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новая рекомендация'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PlaceType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Тип',
                border: OutlineInputBorder(),
              ),
              items: PlaceType.values.map((type) {
                final rec = _Recommendation(
                  id: '',
                  name: '',
                  address: '',
                  type: type,
                  rating: 0,
                  review: '',
                  authorName: '',
                  date: DateTime.now(),
                );
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(rec.typeIcon, size: 20),
                      const SizedBox(width: 8),
                      Text(rec.typeLabel),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Адрес',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Телефон (необяз.)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Оценка: ${_rating.toStringAsFixed(1)}'),
                Slider(
                  value: _rating,
                  min: 1,
                  max: 5,
                  divisions: 8,
                  label: _rating.toStringAsFixed(1),
                  onChanged: (value) => setState(() => _rating = value),
                ),
              ],
            ),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Отзыв',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Ваше имя',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty ||
                _addressController.text.trim().isEmpty ||
                _reviewController.text.trim().isEmpty ||
                _authorController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Заполните все поля')),
              );
              return;
            }

            final rec = _Recommendation(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text.trim(),
              address: _addressController.text.trim(),
              type: _selectedType,
              rating: _rating,
              review: _reviewController.text.trim(),
              authorName: _authorController.text.trim(),
              date: DateTime.now(),
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
            );

            widget.onAdd(rec);
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
