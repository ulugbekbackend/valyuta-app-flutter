import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'koshin.dart';

/// Internet yo'q paytda ekran tepasida turadigan ogohlantirish.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.savedAt,
    required this.onRetry,
  });

  /// Keshdagi kurslar qachon saqlangani.
  final DateTime savedAt;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final saved = DateFormat('dd.MM.yyyy, HH:mm').format(savedAt);

    return Material(
      // Zarhal tusi — koshin palitrasidan, och va to'q fonda ham ishlaydi.
      color: Color.alphaBlend(gold.withValues(alpha: 0.28), colors.surface),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.cloud_off, color: colors.onSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline',
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      'Internet yo\'q. $saved holatidagi saqlangan '
                      'kurslar ko\'rsatilmoqda.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Yangilash')),
            ],
          ),
        ),
      ),
    );
  }
}
