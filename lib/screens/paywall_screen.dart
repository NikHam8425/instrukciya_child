import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payment_service.dart';
import '../services/yookassa_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _loading = false;
  String? _error;
  final _yooKassa = YooKassaService();

  Future<void> _buyAssistantAccess() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Создаем платеж в ЮKassa
      final result = await _yooKassa.createPayment(
        amount: 500.0,
        description: 'Подписка на ассистента "Мамин путь" (30 дней)',
      );

      if (result != null && result['confirmationUrl'] != null) {
        // Открываем страницу оплаты
        final uri = Uri.parse(result['confirmationUrl']!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          
          if (!mounted) return;
          
          // Показываем диалог
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Завершите оплату'),
              content: const Text(
                'После успешной оплаты вернитесь в приложение.\n\n'
                'Доступ к ассистенту будет активирован автоматически.',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Проверяем статус через Cloud Function
                    // Это единственный правильный способ подтверждения
                    
                    // Показываем индикатор загрузки в диалоге, если нужно,
                    // но пока просто блокируем UI ожиданием
                    Navigator.of(context).pop(); // Скрываем диалог на время проверки
                    
                    setState(() { _loading = true; });

                    try {
                      final isActive = await _yooKassa.checkSubscriptionStatus();
                      
                      if (isActive) {
                        await PaymentService().setPremiumStatus(true);
                        // UsageService удален, так как источник правды теперь PaymentService + Firestore
                        
                        if (!mounted) return;
                        Navigator.pop(context, true); // Закрываем paywall успешно
                      } else {
                        if (!mounted) return;
                        setState(() { _loading = false; });
                        
                        // Показываем диалог снова или сообщение
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Платеж еще не подтвержден. Подождите немного и нажмите "Я оплатил" снова.'),
                            duration: Duration(seconds: 4),
                          ),
                        );
                        
                        // Можно снова показать диалог, но проще попросить нажать еще раз
                        // или в реальном приложении сделать polling
                      }
                    } catch (e) {
                      if (!mounted) return;
                      setState(() { _loading = false; });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка проверки: $e')),
                      );
                    }
                  },
                  child: const Text('Я оплатил'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
              ],
            ),
          );
        } else {
          setState(() { _error = 'Не удалось открыть страницу оплаты'; });
        }
      } else {
        setState(() { _error = 'Ошибка создания платежа'; });
      }
    } catch (e) {
      setState(() { _error = 'Ошибка: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Доступ к ассистенту'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Иконка
                      Icon(
                        Icons.auto_awesome,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      
                      // Заголовок
                      Text(
                        'AI-ассистент для родителей',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Описание
                      Text(
                        'Вы использовали 5 бесплатных запросов',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Преимущества
                      _buildFeature(
                        icon: Icons.chat_bubble_outline,
                        title: 'Безлимитные вопросы',
                        subtitle: 'Задавайте любые вопросы о развитии ребенка',
                      ),
                      const SizedBox(height: 16),
                      _buildFeature(
                        icon: Icons.psychology_outlined,
                        title: 'Умный помощник',
                        subtitle: 'Персональные советы на основе AI',
                      ),
                      const SizedBox(height: 16),
                      _buildFeature(
                        icon: Icons.access_time,
                        title: 'Подписка на 30 дней',
                        subtitle: 'Автоматическое продление',
                      ),
                      const SizedBox(height: 24), // Добавил отступ в конце скролла
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Цена
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Подписка',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '500 ₽ / 30 дней',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Ошибка
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Кнопка оплаты
              FilledButton(
                onPressed: _loading ? null : _buyAssistantAccess,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Продолжить пользоваться ассистентом',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              
              // Безопасность
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Безопасная оплата через ЮKassa',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
