import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<String> _progressItems = [];
  Set<int> _checkedItems = {};

  final List<String> _defaultProgressItems = [
    'Купание малыша',
    'Смена подгузника',
    'Кормление грудью',
    'Кормление из бутылочки',
    'Укладывание спать',
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Загружаем список задач
    final itemsJson = prefs.getString('progressItems');
    if (itemsJson != null) {
      final List<dynamic> items = jsonDecode(itemsJson);
      _progressItems = items.cast<String>();
    } else {
      _progressItems = List.from(_defaultProgressItems);
      await _saveProgressItems();
    }

    // Загружаем отмеченные задачи
    final checkedJson = prefs.getString('progressChecked');
    if (checkedJson != null) {
      final List<dynamic> checked = jsonDecode(checkedJson);
      _checkedItems = checked.cast<int>().toSet();
    } else {
      _checkedItems = {};
    }

    setState(() {});
  }

  Future<void> _saveProgressItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('progressItems', jsonEncode(_progressItems));
  }

  Future<void> _saveCheckedItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('progressChecked', jsonEncode(_checkedItems.toList()));
  }

  void _toggleItem(int index) {
    setState(() {
      if (_checkedItems.contains(index)) {
        _checkedItems.remove(index);
      } else {
        _checkedItems.add(index);
      }
    });
    _saveCheckedItems();
  }

  void _addNewItem() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить задачу'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Введите название задачи',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _progressItems.add(controller.text.trim());
                  });
                  _saveProgressItems();
                  Navigator.pop(context);
                }
              },
              child: const Text('Добавить'),
            ),
          ),
        ],
      ),
    );
  }

  void _editItem(int index) {
    final controller = TextEditingController(text: _progressItems[index]);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать задачу'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _progressItems[index] = controller.text.trim();
                  });
                  _saveProgressItems();
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить задачу'),
        content: const Text('Вы уверены, что хотите удалить эту задачу?'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _progressItems.removeAt(index);
                  _checkedItems.remove(index);
                  final newCheckedItems = <int>{};
                  for (final checkedIndex in _checkedItems) {
                    if (checkedIndex < index) {
                      newCheckedItems.add(checkedIndex);
                    } else if (checkedIndex > index) {
                      newCheckedItems.add(checkedIndex - 1);
                    }
                  }
                  _checkedItems = newCheckedItems;
                });
                _saveProgressItems();
                _saveCheckedItems();
                Navigator.pop(context);
              },
              child: const Text('Удалить'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = _progressItems.isEmpty 
        ? 0.0 
        : (_checkedItems.length / _progressItems.length).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Прогресс'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: _addNewItem,
              icon: const Icon(Icons.add_circle_outline, size: 28),
              tooltip: 'Добавить задачу',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          // Прогресс-бар
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Colors.green[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${_checkedItems.length}/${_progressItems.length}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Выполнено задач',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(progressPercentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),

          // Список задач
          _progressItems.isEmpty
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'Нет задач для малыша',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _progressItems.length,
                  itemBuilder: (context, index) {
                    final isChecked = _checkedItems.contains(index);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CheckboxListTile(
                        value: isChecked,
                        onChanged: (_) => _toggleItem(index),
                        title: Text(
                          _progressItems[index],
                          style: TextStyle(
                            fontSize: 16,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            color: isChecked 
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isChecked ? FontWeight.w400 : FontWeight.w500,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        secondary: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _editItem(index);
                                break;
                              case 'delete':
                                _deleteItem(index);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Редактировать'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Удалить'),
                            ),
                          ],
                        ),
                        activeColor: Colors.green[600],
                        checkColor: Colors.white,
                      ),
                    );
                  },
                ),
        ],
        ),
      ),
    );
  }
}