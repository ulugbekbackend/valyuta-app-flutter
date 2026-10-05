import 'package:flutter/material.dart';

import '../utils/fonts.dart';
import '../utils/formatters.dart';

/// Kunlik o'zgarish: o'sgan bo'lsa yashil ▲, tushgan bo'lsa qizil ▼,
/// o'zgarmagan bo'lsa kulrang.
class ChangeText extends StatelessWidget {
  const ChangeText({super.key, required this.diff, this.onDark = false});

  final double diff;

  /// To'q fon (lojuvard taxta) ustida — ranglar ochroq bo'ladi.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (diff > 0) {
      color = onDark ? const Color(0xFF8BE3B2) : const Color(0xFF1B8A4F);
    } else if (diff < 0) {
      color = onDark ? const Color(0xFFFFA59B) : const Color(0xFFC0392B);
    } else {
      color = onDark
          ? Colors.white54
          : Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Text(
      formatChange(diff),
      style: bodyFont(
        Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
