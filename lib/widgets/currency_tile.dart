import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../utils/fonts.dart';
import '../utils/formatters.dart';
import 'change_text.dart';

/// Ro'yxatdagi bitta qator: kod, nom va kurs.
class CurrencyTile extends StatelessWidget {
  const CurrencyTile({super.key, required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Kod — chap ustunda, qat'iy enli, shuning uchun nomlar tekis turadi
          SizedBox(
            width: 52,
            child: Text(
              currency.code,
              style: bodyFont(
                textTheme.titleSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Nom (+ nominal 1 bo'lmasa, izoh)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency.nameUz,
                  style: textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (currency.nominal > 1)
                  Text(
                    '${currency.nominal} ${currency.code} uchun',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Kurs va kunlik o'zgarish — tabular raqamlar, ustunda tekis turadi
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRate(currency.rate),
                style: bodyFont(
                  textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              ChangeText(diff: currency.diff),
            ],
          ),
        ],
      ),
    );
  }
}
