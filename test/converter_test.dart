import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valyuta_app/models/currency.dart';
import 'package:valyuta_app/screens/converter_screen.dart';
import 'package:valyuta_app/utils/formatters.dart';

const _usd = Currency(
  code: 'USD',
  nameUz: 'AQSH dollari',
  nameEn: 'US Dollar',
  nominal: 1,
  rate: 11772.95,
  diff: -35.81,
  date: '03.10.2026',
);

// Kurs 10 birlik uchun: 10 IDR = 6,59 so'm.
const _idr = Currency(
  code: 'IDR',
  nameUz: 'Indoneziya rupiyasi',
  nameEn: 'Indonesian Rupiah',
  nominal: 10,
  rate: 6.59,
  diff: -0.02,
  date: '03.10.2026',
);

void main() {
  group('Currency.toUzs / fromUzs', () {
    test('USD: ikki yo\'nalish', () {
      expect(_usd.toUzs(100), closeTo(1177295, 1e-6));
      expect(_usd.fromUzs(1177295), closeTo(100, 1e-9));
    });

    test('IDR: Nominal=10 hisobga olinadi', () {
      expect(_idr.toUzs(10), closeTo(6.59, 1e-9));
      expect(_idr.toUzs(1000), closeTo(659, 1e-9));
      expect(_idr.fromUzs(6.59), closeTo(10, 1e-9));
      expect(_idr.fromUzs(659), closeTo(1000, 1e-9));
    });

    test('nol summa', () {
      expect(_usd.toUzs(0), 0);
      expect(_usd.fromUzs(0), 0);
    });

    test('kurs 0 bo\'lsa nolga bo\'linmaydi', () {
      const broken = Currency(
        code: 'XXX',
        nameUz: '',
        nameEn: '',
        nominal: 1,
        rate: 0,
        diff: 0,
        date: '',
      );
      expect(broken.fromUzs(100), 0);
    });
  });

  group('parseAmount / amountError', () {
    test('to\'g\'ri qiymatlar', () {
      expect(parseAmount('100'), 100);
      expect(parseAmount('0'), 0);
      expect(parseAmount('12.5'), 12.5);
      expect(parseAmount('12,5'), 12.5); // o'zbekcha vergul
      expect(parseAmount('1 000,5'), 1000.5); // bo'sh joy bilan
      expect(amountError('100'), isNull);
    });

    test('bo\'sh', () {
      expect(parseAmount(''), isNull);
      expect(amountError(''), 'Summani kiriting');
      expect(amountError('   '), 'Summani kiriting');
    });

    test('raqam emas', () {
      expect(parseAmount('abc'), isNull);
      expect(amountError('abc'), 'Faqat raqam kiriting');
      expect(amountError('1.2.3'), 'Faqat raqam kiriting');
      expect(amountError('NaN'), 'Faqat raqam kiriting');
      expect(amountError('Infinity'), 'Faqat raqam kiriting');
    });

    test('manfiy', () {
      expect(parseAmount('-5'), isNull);
      expect(amountError('-5'), "Manfiy bo'lishi mumkin emas");
    });
  });

  group('ConverterScreen', () {
    Widget screen({List<Currency> currencies = const [_usd, _idr]}) =>
        MaterialApp(
          home: Scaffold(
            body: ConverterScreen(
              currencies: currencies,
              isLoading: false,
              onRetry: () {},
            ),
          ),
        );

    Finder resultText(String text) =>
        find.textContaining(text, findRichText: true);

    testWidgets('boshlang\'ich: 100 USD → so\'m', (tester) async {
      await tester.pumpWidget(screen());

      expect(resultText('1 177 295,00'), findsOneWidget);
      expect(find.text("1 USD = 11 772,95 so'm"), findsOneWidget);
    });

    testWidgets('yozilganda natija darhol yangilanadi', (tester) async {
      await tester.pumpWidget(screen());

      await tester.enterText(find.byType(TextField).last, '2');
      await tester.pump();

      expect(resultText('23 545,90'), findsOneWidget);
    });

    testWidgets('almashtirish: so\'m → USD', (tester) async {
      await tester.pumpWidget(screen());

      await tester.enterText(find.byType(TextField).last, '1177295');
      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pump();

      expect(resultText('100,00'), findsOneWidget);
    });

    testWidgets('IDR tanlansa Nominal hisobga olinadi', (tester) async {
      await tester.pumpWidget(screen());

      await tester.tap(find.byType(DropdownMenu<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('IDR — Indoneziya rupiyasi').last);
      await tester.pumpAndSettle();

      // 100 IDR = 100 × 6,59 / 10 = 65,90 so'm
      expect(resultText('65,90'), findsOneWidget);
      expect(find.text("10 IDR = 6,59 so'm"), findsOneWidget);
    });

    testWidgets('xato kiritishda xabar chiqadi', (tester) async {
      await tester.pumpWidget(screen());
      final field = find.byType(TextField).last;

      await tester.enterText(field, '');
      await tester.pump();
      expect(find.text('Summani kiriting'), findsOneWidget);

      await tester.enterText(field, 'abc');
      await tester.pump();
      expect(find.text('Faqat raqam kiriting'), findsOneWidget);

      await tester.enterText(field, '-3');
      await tester.pump();
      expect(find.text("Manfiy bo'lishi mumkin emas"), findsOneWidget);
      expect(resultText('— UZS'), findsOneWidget); // natija yo'q
    });

    testWidgets('kurslar bo\'lmasa xabar chiqadi', (tester) async {
      await tester.pumpWidget(screen(currencies: const []));

      expect(find.textContaining('kurslar kerak'), findsOneWidget);
    });
  });
}
