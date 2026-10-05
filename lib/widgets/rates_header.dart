import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../utils/fonts.dart';
import '../utils/formatters.dart';

// Samarqand koshinlaridan olingan ranglar.
const lapis = Color(0xFF173F73); // lojuvard ko'k
const _turquoise = Color(0xFF2BB3B1); // firuza
const _gold = Color(0xFFE2B44A); // zarhal

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

    return Container(
      width: double.infinity, // ustun kengligini to'liq egallaydi
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: lapis,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias, // naqsh burchakdan chiqib ketmasin
      child: CustomPaint(
        painter: _GirihPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
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
                          textTheme.titleMedium?.copyWith(color: _gold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(height: 2, width: 48, color: _gold),
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
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Koshin naqshi: 8 qirrali yulduzlar (ikki kvadrat, biri 45° burilgan).
/// CustomPainter — HTML'dagi <canvas> ga chizish bilan bir xil.
class _GirihPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _turquoise.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const step = 56.0; // yulduzlar orasidagi masofa
    const r = 18.0; // yulduz kattaligi

    // Naqsh faqat o'ng tomonda — chapdagi raqamlar o'qilishi oson bo'lsin.
    for (var x = size.width * 0.45; x < size.width + step; x += step) {
      for (var y = 0.0; y < size.height + step; y += step) {
        final center = Offset(x, y);
        canvas.drawPath(_square(center, r, 0), paint);
        canvas.drawPath(_square(center, r, math.pi / 4), paint);
      }
    }
  }

  Path _square(Offset c, double r, double angle) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = angle + i * math.pi / 2;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
