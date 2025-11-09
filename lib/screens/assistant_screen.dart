import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/openai_service.dart';
import '../services/payment_service.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _ctrl = TextEditingController();
  final List<(String, bool)> _messages = []; // (text, isUser)
  bool _loading = false;
  final _openAI = OpenAIService();
  final _paymentService = PaymentService();
  ChildProfile? _childProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ChildProfile.load();
    setState(() => _childProfile = profile);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    // Проверяем лимит бесплатных обращений
    if (!await _paymentService.canPerformAction()) {
      if (!mounted) return;
      _showSubscriptionDialog();
      return;
    }

    setState(() {
      _messages.add((text, true));
      _loading = true;
      _ctrl.clear();
    });

    try {
      // Увеличиваем счетчик
      await _paymentService.performAction();
      
      final response = await _openAI.askWithChildProfile(
        userMessage: text,
        child: _childProfile,
      );
      setState(() {
        _messages.add((response, false));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(('Извините, произошла ошибка. Попробуйте ещё раз.', false));
        _loading = false;
      });
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 8),
            Text('Лимит исчерпан'),
          ],
        ),
        content: const Text(
          'У вас закончились бесплатные обращения к GPT-ассистенту.\n\n'
          'Оформите Premium подписку для получения безлимитного доступа.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _paymentService.buyPro();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✨ Premium подписка активирована!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.star),
            label: const Text('Оформить Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ассистент'),
        actions: [
          // Счетчик обращений
          FutureBuilder<Map<String, dynamic>>(
            future: _getSubscriptionInfo(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              
              final data = snapshot.data!;
              final isPremium = data['isPremium'] as bool;
              final remaining = data['remaining'] as int;
              
              if (isPremium) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        SizedBox(width: 4),
                        Text('Premium', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    '$remaining/5',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: remaining > 0 ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
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

  Future<Map<String, dynamic>> _getSubscriptionInfo() async {
    final isPremium = await _paymentService.isPremium();
    final remaining = await _paymentService.getRemainingFreeActions();
    return {'isPremium': isPremium, 'remaining': remaining};
  }
}


