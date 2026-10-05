/// CBU API'dan kelgan bitta valyuta kursi.
///
/// API'da `Rate`, `Diff` va `Nominal` string ko'rinishida keladi,
/// shuning uchun ular xavfsiz parse qilinadi.
class Currency {
  const Currency({
    required this.code,
    required this.nameUz,
    required this.nameEn,
    required this.nominal,
    required this.rate,
    required this.diff,
    required this.date,
  });

  final String code; // "USD"
  final String nameUz; // "AQSH dollari"
  final String nameEn; // "US Dollar"
  final int nominal; // kurs nechta birlik uchun (1 yoki 10)
  final double rate; // `nominal` birlik uchun so'mdagi narx
  final double diff; // kechagi kunga nisbatan o'zgarish
  final String date; // "03.10.2026"

  factory Currency.fromJson(Map<String, dynamic> json) {
    final nominal = _toInt(json['Nominal']);
    return Currency(
      code: json['Ccy']?.toString() ?? '',
      nameUz: json['CcyNm_UZ']?.toString() ?? '',
      nameEn: json['CcyNm_EN']?.toString() ?? '',
      // Nominal 0 yoki manfiy bo'lsa, bo'lishda xato chiqmasligi uchun 1.
      nominal: nominal != null && nominal > 0 ? nominal : 1,
      rate: _toDouble(json['Rate']) ?? 0,
      diff: _toDouble(json['Diff']) ?? 0,
      date: json['Date']?.toString() ?? '',
    );
  }

  /// 1 birlik valyutaning so'mdagi narxi.
  double get ratePerUnit => rate / nominal;

  @override
  String toString() => 'Currency($code, $nominal = $rate UZS, diff: $diff)';
}

double? _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

int? _toInt(Object? value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value.trim());
  return null;
}
