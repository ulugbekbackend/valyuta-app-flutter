import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../utils/fonts.dart';
import '../utils/formatters.dart';
import 'change_text.dart';
import 'koshin.dart';

/// Ro'yxat tepasidagi "kurs taxtasi": asosiy valyuta katta,
/// qolgan pinned valyutalar pastda kichikroq.
class RatesHeader extends StatelessWidget {
  const RatesHeader({super.key, required this.pinned});

  /// USD, EUR, RUB (shu tartibda). Birinchisi katta ko'rsatiladi.
  final List<Currency> pinned;

  @override
  Widget build(BuildContext context) {
    if (pinned.isEmpty) return const SizedBox.shrink();

    final main = pinned.first;
    final others = pinned.skip(1);
    final textTheme = Theme.of(context).textTheme;
    const tabular = [FontFeature.tabularFigures()];

    return KoshinPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${main.nominal} ${main.nameUz}',
            style: textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          FittedBox(
            // tor ekranda raqam sig'masa, kichrayadi
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: formatRate(main.rate),
                    style: displayFont(
                      textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFeatures: tabular,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: " so'm",
                    style: displayFont(
                      textTheme.titleMedium?.copyWith(color: gold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ChangeText(diff: main.diff, onDark: true),
          const SizedBox(height: 16),
          Container(height: 2, width: 48, color: gold),
          const SizedBox(height: 16),
          Wrap(
            spacing: 32,
            runSpacing: 8,
            children: [
              for (final c in others)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.nameUz,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      formatRate(c.rate),
                      style: displayFont(
                        textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFeatures: tabular,
                        ),
                      ),
                    ),
                    ChangeText(diff: c.diff, onDark: true),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
