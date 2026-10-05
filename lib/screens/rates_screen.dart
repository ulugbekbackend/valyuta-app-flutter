import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../widgets/currency_tile.dart';

/// Kurslar ro'yxati. Ma'lumotni o'zi yuklamaydi — ota widget (HomePage)
/// beradi, bu ekran faqat ko'rsatadi.
class RatesScreen extends StatelessWidget {
  const RatesScreen({
    super.key,
    required this.currencies,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final List<Currency> currencies;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: currencies.length,
      itemBuilder: (context, index) =>
          CurrencyTile(currency: currencies[index]),
    );
  }
}
