import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../services/usage_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _buy() async {
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await PaymentService().buyPro();
      if (ok) {
        await UsageService().markPro(true);
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        setState(() { _error = 'Покупка не состоялась'; });
      }
    } catch (e) {
      setState(() { _error = 'Ошибка: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ассистент PRO')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('5 сообщений бесплатно'),
            const SizedBox(height: 8),
            const Text('Далее — безлимит по подписке.'),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            FilledButton(
              onPressed: _loading ? null : _buy,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Оформить PRO'),
            ),
          ],
        ),
      ),
    );
  }
}
