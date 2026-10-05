import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../services/currency_service.dart';
import '../utils/fonts.dart';
import '../widgets/currency_tile.dart';
import '../widgets/rates_header.dart';

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

    // USD/EUR/RUB tepadagi taxtaga, qolganlari pastdagi ro'yxatga.
    final pinned = currencies
        .where((c) => pinnedCodes.contains(c.code))
        .toList();
    final others = currencies
        .where((c) => !pinnedCodes.contains(c.code))
        .toList();
    final textTheme = Theme.of(context).textTheme;

    // Keng ekranda (desktop) cho'zilib ketmasligi uchun eni cheklanadi.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          // +1: birinchi element — taxta va sarlavha
          itemCount: others.length + 1,
          separatorBuilder: (context, index) => index == 0
              ? const SizedBox.shrink()
              : const Divider(height: 1, indent: 24, endIndent: 24),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatesHeader(pinned: pinned),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                    child: Text(
                      'Boshqa valyutalar',
                      style: bodyFont(
                        textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return CurrencyTile(currency: others[index - 1]);
          },
        ),
      ),
    );
  }
}
