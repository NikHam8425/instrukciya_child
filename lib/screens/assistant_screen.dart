import 'package:flutter/material.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _ctrl = TextEditingController();
  final List<(String, bool)> _messages = []; // (text, isUser)
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add((text, true));
      _loading = true;
      _ctrl.clear();
    });
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _messages.add(('(Заглушка) Ассистент скоро будет подключён к OpenAI.', false));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ассистент')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final (text, isUser) = _messages[i];
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser ? Theme.of(context).colorScheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_loading) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(hintText: 'Спросите об уходе и развитии...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(onPressed: _send, icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


