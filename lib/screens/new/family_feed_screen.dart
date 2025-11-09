import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

enum EventType { milestone, photo, note, medical, achievement }

class FamilyEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final EventType type;
  final List<String> tags;

  const FamilyEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'type': type.name,
        'tags': tags,
      };

  factory FamilyEvent.fromJson(Map<String, dynamic> json) => FamilyEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
        type: EventType.values.firstWhere((e) => e.name == json['type']),
        tags: List<String>.from(json['tags'] ?? []),
      );

  String get typeEmoji {
    switch (type) {
      case EventType.milestone:
        return '🎯';
      case EventType.photo:
        return '📸';
      case EventType.note:
        return '📝';
      case EventType.medical:
        return '🏥';
      case EventType.achievement:
        return '🏆';
    }
  }

  String get typeLabel {
    switch (type) {
      case EventType.milestone:
        return 'Важное событие';
      case EventType.photo:
        return 'Фото';
      case EventType.note:
        return 'Заметка';
      case EventType.medical:
        return 'Медицина';
      case EventType.achievement:
        return 'Достижение';
    }
  }
}

class FamilyFeedScreen extends StatefulWidget {
  const FamilyFeedScreen({super.key});

  @override
  State<FamilyFeedScreen> createState() => _FamilyFeedScreenState();
}

class _FamilyFeedScreenState extends State<FamilyFeedScreen> {
  List<FamilyEvent> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString('familyEvents');

    if (eventsString != null) {
      try {
        final jsonList = jsonDecode(eventsString) as List;
        setState(() {
          _events = jsonList
              .map((json) => FamilyEvent.fromJson(json as Map<String, dynamic>))
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

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _events.map((e) => e.toJson()).toList();
    await prefs.setString('familyEvents', jsonEncode(jsonList));
  }

  Future<void> _addEvent(FamilyEvent event) async {
    setState(() {
      _events.insert(0, event);
    });
    await _saveEvents();
  }

  Future<void> _deleteEvent(String id) async {
    setState(() {
      _events.removeWhere((e) => e.id == id);
    });
    await _saveEvents();
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddEventDialog(
        onAdd: (event) {
          _addEvent(event);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лента семьи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_note, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Пока нет событий',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Добавьте первое событие!',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _showAddEventDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить событие'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return _EventCard(
                      event: event,
                      onDelete: () => _deleteEvent(event.id),
                    );
                  },
                ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final FamilyEvent event;
  final VoidCallback onDelete;

  const _EventCard({required this.event, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm', 'ru');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(event.typeEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event.typeLabel,
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
                        title: const Text('Удалить событие?'),
                        content: const Text('Это действие нельзя отменить.'),
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
            Text(event.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(event.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (event.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: event.tags
                    .map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddEventDialog extends StatefulWidget {
  final Function(FamilyEvent) onAdd;

  const _AddEventDialog({required this.onAdd});

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  EventType _selectedType = EventType.milestone;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новое событие'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Тип события',
                border: OutlineInputBorder(),
              ),
              items: EventType.values.map((type) {
                final event = FamilyEvent(
                  id: '',
                  title: '',
                  description: '',
                  date: DateTime.now(),
                  type: type,
                );
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(event.typeEmoji),
                      const SizedBox(width: 8),
                      Text(event.typeLabel),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('d MMMM yyyy, HH:mm', 'ru')
                  .format(_selectedDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
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
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Введите название')),
              );
              return;
            }

            final event = FamilyEvent(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              date: _selectedDate,
              type: _selectedType,
            );

            widget.onAdd(event);
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
