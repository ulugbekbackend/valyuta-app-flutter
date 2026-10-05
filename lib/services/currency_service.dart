import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/currency.dart';

/// CBU (Markaziy bank) API'dan valyuta kurslarini yuklaydi.
class CurrencyService {
  /// [client] testlarda soxta (mock) client berish uchun.
  CurrencyService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _url = Uri.parse(
    'https://cbu.uz/uz/arkhiv-kursov-valyut/json/',
  );

  final http.Client _client;

  Future<List<Currency>> fetchRates() async {
    final response = await _client
        .get(_url)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Server xatosi: ${response.statusCode}');
    }
    // Server charset yubormaydi, shuning uchun UTF-8 ni o'zimiz belgilaymiz.
    return parseRates(utf8.decode(response.bodyBytes));
  }
}

/// Eng ko'p ishlatiladigan valyutalar ro'yxat tepasida shu tartibda turadi.
const pinnedCodes = ['USD', 'EUR', 'RUB'];

/// Avval [pinnedCodes], qolganlari kod bo'yicha alifbo tartibida.
List<Currency> sortCurrencies(List<Currency> currencies) {
  final pinned = <Currency>[];
  for (final code in pinnedCodes) {
    pinned.addAll(currencies.where((c) => c.code == code));
  }
  final others = currencies.where((c) => !pinnedCodes.contains(c.code)).toList()
    ..sort((a, b) => a.code.compareTo(b.code));
  return [...pinned, ...others];
}

/// JSON matnni valyutalar ro'yxatiga aylantiradi.
List<Currency> parseRates(String body) {
  final data = jsonDecode(body) as List<dynamic>;
  return data
      .map((item) => Currency.fromJson(item as Map<String, dynamic>))
      .toList();
}
