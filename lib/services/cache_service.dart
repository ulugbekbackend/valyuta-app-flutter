import 'package:shared_preferences/shared_preferences.dart';

/// Keshdan o'qilgan ma'lumot: API'ning xom JSON javobi va saqlangan vaqt.
class CachedRates {
  const CachedRates({required this.body, required this.savedAt});

  final String body;
  final DateTime savedAt;
}

/// Oxirgi muvaffaqiyatli API javobini qurilmada saqlaydi.
/// shared_preferences — kalit/qiymat ombori: web'da localStorage,
/// Android'da SharedPreferences (Django'dagi oddiy key-value cache kabi).
class CacheService {
  /// [clock] testlarda vaqtni aniq berish uchun.
  CacheService({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static const _bodyKey = 'rates_body';
  static const _savedAtKey = 'rates_saved_at';

  final DateTime Function() _clock;

  Future<void> saveRates(String body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bodyKey, body);
    await prefs.setString(_savedAtKey, _clock().toIso8601String());
  }

  /// Kesh bo'sh yoki buzilgan bo'lsa — null.
  Future<CachedRates?> loadRates() async {
    final prefs = await SharedPreferences.getInstance();
    final body = prefs.getString(_bodyKey);
    final savedAt = DateTime.tryParse(prefs.getString(_savedAtKey) ?? '');
    if (body == null || savedAt == null) return null;
    return CachedRates(body: body, savedAt: savedAt);
  }
}
