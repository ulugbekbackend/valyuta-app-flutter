import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valyuta_app/main.dart';
import 'package:valyuta_app/services/cache_service.dart';
import 'package:valyuta_app/services/currency_service.dart';

const _usdJson = {
  'Ccy': 'USD',
  'CcyNm_UZ': 'AQSH dollari',
  'CcyNm_EN': 'US Dollar',
  'Nominal': '1',
  'Rate': '11772.95',
  'Diff': '-35.81',
  'Date': '03.10.2026',
};

final _savedAt = DateTime(2026, 10, 5, 19, 30);
final _body = jsonEncode([_usdJson]);

MockClient _okClient() =>
    MockClient((_) async => http.Response.bytes(utf8.encode(_body), 200));

// Internet yo'qligini taqlid qiladi.
MockClient _offlineClient() =>
    MockClient((_) async => throw http.ClientException('Internet yo\'q'));

void main() {
  // Har testdan oldin bo'sh "localStorage".
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('CacheService', () {
    test('bo\'sh bo\'lsa null', () async {
      expect(await CacheService().loadRates(), isNull);
    });

    test('saqlangan javob va vaqtni qaytaradi', () async {
      final cache = CacheService(clock: () => _savedAt);

      await cache.saveRates(_body);
      final cached = await cache.loadRates();

      expect(cached?.body, _body);
      expect(cached?.savedAt, _savedAt);
    });
  });

  group('CurrencyService.loadRates', () {
    test('internet bor: yangi ma\'lumot va keshga yozadi', () async {
      final cache = CacheService(clock: () => _savedAt);
      final service = CurrencyService(client: _okClient(), cache: cache);

      final result = await service.loadRates();

      expect(result.fromCache, isFalse);
      expect(result.currencies.single.code, 'USD');
      expect((await cache.loadRates())?.body, _body);
    });

    test('internet yo\'q, kesh bor: keshdan', () async {
      final cache = CacheService(clock: () => _savedAt);
      await cache.saveRates(_body);
      final service = CurrencyService(client: _offlineClient(), cache: cache);

      final result = await service.loadRates();

      expect(result.fromCache, isTrue);
      expect(result.savedAt, _savedAt);
      expect(result.currencies.single.rate, 11772.95);
    });

    test('internet yo\'q, kesh yo\'q: xato', () async {
      final service = CurrencyService(client: _offlineClient());

      expect(service.loadRates(), throwsA(isA<http.ClientException>()));
    });

    test('server buzilgan JSON qaytarsa keshni buzmaydi', () async {
      final cache = CacheService(clock: () => _savedAt);
      await cache.saveRates(_body);
      final brokenClient = MockClient(
        (_) async => http.Response('<html>', 200),
      );
      final service = CurrencyService(client: brokenClient, cache: cache);

      final result = await service.loadRates();

      expect(result.fromCache, isTrue); // eski to'g'ri ma'lumot
      expect((await cache.loadRates())?.body, _body);
    });
  });

  group('HomePage offline banner', () {
    testWidgets('internet yo\'q bo\'lsa banner va kesh ko\'rinadi', (
      tester,
    ) async {
      await CacheService(clock: () => _savedAt).saveRates(_body);
      final service = CurrencyService(client: _offlineClient());

      await tester.pumpWidget(MaterialApp(home: HomePage(service: service)));
      await tester.pumpAndSettle();

      expect(find.text('Offline'), findsOneWidget);
      expect(find.textContaining('05.10.2026, 19:30'), findsOneWidget);
      expect(find.text('1 AQSH dollari'), findsOneWidget); // keshdagi kurs
    });

    testWidgets('internet bor bo\'lsa banner yo\'q', (tester) async {
      final service = CurrencyService(client: _okClient());

      await tester.pumpWidget(MaterialApp(home: HomePage(service: service)));
      await tester.pumpAndSettle();

      expect(find.text('Offline'), findsNothing);
      expect(find.text('1 AQSH dollari'), findsOneWidget);
    });

    testWidgets('tablar orasida o\'tish', (tester) async {
      final service = CurrencyService(client: _okClient());

      await tester.pumpWidget(MaterialApp(home: HomePage(service: service)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Konvertor').last);
      await tester.pumpAndSettle();

      expect(find.text('Berasiz'), findsOneWidget);
    });
  });
}
