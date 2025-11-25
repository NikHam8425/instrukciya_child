// lib/screens/new/family_feed_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

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
      case EventType.milestone: return '🎯';
      case EventType.photo: return '📸';
      case EventType.note: return '📝';
      case EventType.medical: return '🏥';
      case EventType.achievement: return '🏆';
    }
  }

  String get typeLabel {
    switch (type) {
      case EventType.milestone: return 'Важное событие';
      case EventType.photo: return 'Фото';
      case EventType.note: return 'Заметка';
      case EventType.medical: return 'Медицина';
      case EventType.achievement: return 'Достижение';
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

  // ←←←←← НОВАЯ ФУНКЦИЯ: экспорт в PDF ←←←←←
  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        header: (context) => pw.Center(
          child: pw.Text(
            'Семейная лента «Мамин путь»',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Сгенерировано ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        build: (context) => _events.map((e) {
          return pw.Container(
            margin: pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(e.typeEmoji, style: const pw.TextStyle(fontSize: 20)),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      e.title,
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(e.description),
                pw.SizedBox(height: 6),
                pw.Text(
                  '${e.typeLabel} • ${DateFormat('d MMMM yyyy, HH:mm', 'ru').format(e.date)}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                if (e.tags.isNotEmpty)
                  pw.Wrap(
                    children: e.tags
                        .map((tag) => pw.Container(
                              padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: pw.EdgeInsets.only(right: 6, top: 6),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey300,
                                borderRadius: pw.BorderRadius.circular(12),
                              ),
                              child: pw.Text(tag, style: const pw.TextStyle(fontSize: 10)),
                            ))
                        .toList(),
                  ),
                pw.Divider(height: 30),
              ],
            ),
          );
        }).toList(),
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/family_feed_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Семейная лента из приложения «Мамин путь»',
    );
  }

  void _showInviteDialog() {
    // твой старый код приглашения оставил без изменений
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пригласить в семью'),
        content: const Text('Поделись кодом family-invite-code-12345'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
          FilledButton.icon(
            onPressed: () {
              Share.share('Присоединяйся! Код: family-invite-code-12345');
              Navigator.pop(context);
            },
            icon: const Icon(Icons.share),
            label: const Text('Поделиться'),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddEventDialog(onAdd: _addEvent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лента семьи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Пригласить',
            onPressed: _showInviteDialog,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Экспорт в PDF',
            onPressed: _events.isEmpty ? null : _exportToPdf,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadEvents();
              },
              child: _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_note, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('Пока нет событий', style: TextStyle(fontSize: 18, color: Colors.grey)),
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
            ),
    );
  }
}

// Всё остальное оставил 100% как у тебя было (карточки, диалог добавления и т.д.)

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
                      Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(event.typeLabel, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Удалить?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
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
                Text(dateFormat.format(event.date), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            if (event.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: event.tags
                    .map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
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
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Тип события', border: OutlineInputBorder()),
              items: EventType.values.map((type) {
                final dummy = FamilyEvent(id: '', title: '', description: '', date: DateTime.now(), type: type);
                return DropdownMenuItem(value: type, child: Row(children: [Text(dummy.typeEmoji), const SizedBox(width: 8), Text(dummy.typeLabel)]));
              }).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('d MMMM yyyy, HH:mm', 'ru').format(_selectedDate)),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2015), lastDate: DateTime.now());
                if (date != null) {
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedDate));
                  if (time != null) {
                    setState(() => _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                  }
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) return;
            final event = FamilyEvent(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              date: _selectedDate,
              type: _selectedType,
            );
            widget.onAdd(event);
            Navigator.pop(context);
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}