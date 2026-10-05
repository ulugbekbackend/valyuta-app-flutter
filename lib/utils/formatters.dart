import 'package:intl/intl.dart';

final _number = NumberFormat('#,##0.00', 'en_US');

/// 12650.5 → "12 650,50" (o'zbekcha ko'rinish: minglik bo'sh joy, kasr vergul).
String formatRate(double value) {
  // en_US: "12,650.50" → avval vergulni bo'sh joyga, keyin nuqtani vergulga.
  return _number.format(value).replaceAll(',', ' ').replaceAll('.', ',');
}

/// Kunlik o'zgarish: 35.81 → "▲ 35,81", -35.81 → "▼ 35,81", 0 → "0,00".
String formatChange(double value) {
  final text = formatRate(value.abs());
  if (value > 0) return '▲ $text';
  if (value < 0) return '▼ $text';
  return text;
}
