import 'dart:math' as math;

import 'package:flutter/material.dart';

// Samarqand koshinlaridan olingan ranglar.
const lapis = Color(0xFF173F73); // lojuvard ko'k
const turquoise = Color(0xFF2BB3B1); // firuza
const gold = Color(0xFFE2B44A); // zarhal

/// Lojuvard rangli, girih naqshli panel. Kurs taxtasi va konvertor
/// natijasi uchun umumiy "qobiq" (React'dagi umumiy `<Panel>` komponenti kabi).
class KoshinPanel extends StatelessWidget {
  const KoshinPanel({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 16),
  });

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ustun kengligini to'liq egallaydi
      margin: margin,
      decoration: BoxDecoration(
        color: lapis,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias, // naqsh burchakdan chiqib ketmasin
      child: CustomPaint(
        painter: _GirihPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: child,
        ),
      ),
    );
  }
}

/// Koshin naqshi: 8 qirrali yulduzlar (ikki kvadrat, biri 45° burilgan).
/// CustomPainter — HTML'dagi `<canvas>` ga chizish bilan bir xil.
class _GirihPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = turquoise.withValues(alpha: 0.18)
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
