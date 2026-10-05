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

  group('formatDiff', () {
    test('ishorani ko\'rsatadi', () {
      expect(formatDiff(35.81), '+35,81');
      expect(formatDiff(-179.57), '-179,57');
      expect(formatDiff(0), '0,00');
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
}
