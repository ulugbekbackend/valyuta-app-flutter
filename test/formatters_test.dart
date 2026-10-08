import 'package:flutter_test/flutter_test.dart';
import 'package:valyuta_app/models/currency.dart';
import 'package:valyuta_app/services/currency_service.dart';
import 'package:valyuta_app/utils/formatters.dart';

Currency _currency(String code) => Currency(
  code: code,
  nameUz: code,
  nameEn: code,
  nominal: 1,
  rate: 1,
  diff: 0,
  date: '03.10.2026',
);

void main() {
  group('formatRate', () {
    test('minglikni bo\'sh joy, kasrni vergul bilan ajratadi', () {
      expect(formatRate(12650.5), '12 650,50');
      expect(formatRate(11772.95), '11 772,95');
    });

    test('kichik va katta sonlar', () {
      expect(formatRate(0.07), '0,07');
      expect(formatRate(141.14), '141,14');
      expect(formatRate(1234567.891), '1 234 567,89');
    });
  });

  group('formatChange', () {
    test('o\'sish ▲, tushish ▼, o\'zgarmagan — belgisiz', () {
      expect(formatChange(35.81), '▲ 35,81');
      expect(formatChange(-179.57), '▼ 179,57');
      expect(formatChange(0), '0,00');
    });
  });

  group('sortCurrencies', () {
    test('USD, EUR, RUB tepada, qolganlari alifbo bo\'yicha', () {
      final input = ['JPY', 'RUB', 'AED', 'USD', 'GBP', 'EUR'].map(_currency);

      final sorted = sortCurrencies(input.toList()).map((c) => c.code);

      expect(sorted, ['USD', 'EUR', 'RUB', 'AED', 'GBP', 'JPY']);
    });

    test('pinned valyuta yo\'q bo\'lsa ham ishlaydi', () {
      final sorted = sortCurrencies([_currency('JPY'), _currency('AED')])
          .map((c) => c.code);

      expect(sorted, ['AED', 'JPY']);
    });
  });

  group('filterCurrencies', () {
    final list = [
      _named('USD', 'AQSH dollari'),
      _named('AUD', 'Avstraliya dollari'),
      _named('RUB', 'Rossiya rubli'),
      _named('AFN', 'Afgʻoniston afgʻonisi'), // API'dagi "ʻ" belgisi
    ];
    List<String> codes(String q) =>
        filterCurrencies(list, q).map((c) => c.code).toList();

    test('bo\'sh so\'rov — hammasi', () {
      expect(codes(''), ['USD', 'AUD', 'RUB', 'AFN']);
      expect(codes('   '), ['USD', 'AUD', 'RUB', 'AFN']);
    });

    test('kod bo\'yicha, katta-kichik harf farqsiz', () {
      expect(codes('usd'), ['USD']);
      expect(codes('RU'), ['RUB']);
    });

    test('nom bo\'yicha', () {
      expect(codes('dollar'), ['USD', 'AUD']);
      expect(codes(' Rubl '), ['RUB']);
    });

    test('oddiy apostrof "ʻ" bilan ham topadi', () {
      expect(codes("afg'on"), ['AFN']);
    });

    test('mos kelmasa — bo\'sh', () {
      expect(codes('xyz'), isEmpty);
    });
  });
}

Currency _named(String code, String nameUz) => Currency(
  code: code,
  nameUz: nameUz,
  nameEn: code,
  nominal: 1,
  rate: 1,
  diff: 0,
  date: '03.10.2026',
);
