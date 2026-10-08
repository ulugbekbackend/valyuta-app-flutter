import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/currency.dart';
import 'cache_service.dart';

/// [CurrencyService.loadRates] natijasi: kurslar va ular qayerdan kelgani.
class RatesResult {
  const RatesResult({
    required this.currencies,
    required this.fromCache,
    this.savedAt,
  });

  final List<Currency> currencies;

  /// true — internet yo'q, keshdagi eski ma'lumot ko'rsatilmoqda.
  final bool fromCache;

  /// Keshdan bo'lsa — qachon saqlangani.
  final DateTime? savedAt;
}

/// CBU (Markaziy bank) API'dan valyuta kurslarini yuklaydi.
class CurrencyService {
  /// [client] va [cache] testlarda soxta (mock) qiymat berish uchun.
  CurrencyService({http.Client? client, CacheService? cache})
    : _client = client ?? http.Client(),
      _cache = cache ?? CacheService();

  static final Uri _url = Uri.parse(
    'https://cbu.uz/uz/arkhiv-kursov-valyut/json/',
  );

  final http.Client _client;
  final CacheService _cache;

  /// Faqat internetdan (keshsiz).
  Future<List<Currency>> fetchRates() async => parseRates(await _fetchBody());

  /// Avval internetdan; muvaffaqiyatli bo'lsa keshga yozadi.
  /// Internet ishlamasa — keshdan. Kesh ham bo'lmasa — xato.
  Future<RatesResult> loadRates() async {
    try {
      final body = await _fetchBody();
      final currencies = parseRates(body); // avval tekshiramiz, keyin saqlaymiz
      await _cache.saveRates(body);
      return RatesResult(currencies: currencies, fromCache: false);
    } catch (networkError) {
      final cached = await _cache.loadRates();
      if (cached == null) rethrow; // ko'rsatadigan hech narsa yo'q
      return RatesResult(
        currencies: parseRates(cached.body),
        fromCache: true,
        savedAt: cached.savedAt,
      );
    }
  }

  Future<String> _fetchBody() async {
    final response = await _client
        .get(_url)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Server xatosi: ${response.statusCode}');
    }
    // Server charset yubormaydi, shuning uchun UTF-8 ni o'zimiz belgilaymiz.
    return utf8.decode(response.bodyBytes);
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

/// Kod yoki o'zbekcha nom bo'yicha qidiradi (katta-kichik harf farqsiz).
/// Bo'sh so'rov bo'lsa, hammasini qaytaradi.
List<Currency> filterCurrencies(List<Currency> currencies, String query) {
  final q = _normalize(query);
  if (q.isEmpty) return currencies;
  return currencies
      .where(
        (c) =>
            _normalize(c.code).contains(q) || _normalize(c.nameUz).contains(q),
      )
      .toList();
}

/// API nomlarda "ʻ" (Afgʻoniston) ishlatadi, foydalanuvchi esa odatda "'"
/// yozadi — ikkalasini bir xil deb hisoblaymiz.
String _normalize(String text) =>
    text.trim().toLowerCase().replaceAll(RegExp('[ʻʼ‘’`]'), "'");

/// JSON matnni valyutalar ro'yxatiga aylantiradi.
List<Currency> parseRates(String body) {
  final data = jsonDecode(body) as List<dynamic>;
  return data
      .map((item) => Currency.fromJson(item as Map<String, dynamic>))
      .toList();
}
