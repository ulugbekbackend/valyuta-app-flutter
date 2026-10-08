import 'package:intl/intl.dart';

final _number = NumberFormat('#,##0.00', 'en_US');

/// 12650.5 → "12 650,50" (o'zbekcha ko'rinish: minglik bo'sh joy, kasr vergul).
String formatRate(double value) {
  // en_US: "12,650.50" → avval vergulni bo'sh joyga, keyin nuqtani vergulga.
  return _number.format(value).replaceAll(',', ' ').replaceAll('.', ',');
}

/// "1 000,5" → "1000.5": bo'sh joylar olib tashlanadi, vergul nuqtaga.
double? _tryParse(String text) {
  final value = double.tryParse(
    text.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.'),
  );
  // "NaN" va "Infinity" ham double.tryParse'dan o'tadi — ularni rad etamiz.
  return value == null || !value.isFinite ? null : value;
}

/// Summa xato bo'lsa — foydalanuvchiga xabar, to'g'ri bo'lsa — null.
String? amountError(String text) {
  if (text.trim().isEmpty) return 'Summani kiriting';
  final value = _tryParse(text);
  if (value == null) return 'Faqat raqam kiriting';
  if (value < 0) return "Manfiy bo'lishi mumkin emas";
  return null;
}

/// Foydalanuvchi kiritgan summa: "1 000,5" → 1000.5.
/// Bo'sh, raqam emas yoki manfiy bo'lsa — null.
double? parseAmount(String text) =>
    amountError(text) == null ? _tryParse(text) : null;

/// Kunlik o'zgarish: 35.81 → "▲ 35,81", -35.81 → "▼ 35,81", 0 → "0,00".
String formatChange(double value) {
  final text = formatRate(value.abs());
  if (value > 0) return '▲ $text';
  if (value < 0) return '▼ $text';
  return text;
}
