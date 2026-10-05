import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valyuta_app/models/currency.dart';
import 'package:valyuta_app/screens/rates_screen.dart';

const _usd = Currency(
  code: 'USD',
  nameUz: 'AQSH dollari',
  nameEn: 'US Dollar',
  nominal: 1,
  rate: 11772.95,
  diff: -35.81,
  date: '03.10.2026',
);

const _idr = Currency(
  code: 'IDR',
  nameUz: 'Indoneziya rupiyasi',
  nameEn: 'Indonesian Rupiah',
  nominal: 10,
  rate: 6.59,
  diff: -0.02,
  date: '03.10.2026',
);

/// RatesScreen'ni ota widgetsiz, soxta ma'lumot bilan chizadi.
Widget _wrap(RatesScreen screen) => MaterialApp(home: Scaffold(body: screen));

void main() {
  testWidgets('ro\'yxatni ko\'rsatadi', (tester) async {
    await tester.pumpWidget(
      _wrap(
        RatesScreen(
          currencies: const [_usd, _idr],
          isLoading: false,
          error: null,
          onRetry: () {},
        ),
      ),
    );

    expect(find.text('1 AQSH dollari'), findsOneWidget); // taxtada
    expect(
      find.textContaining('11 772,95', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('10 IDR uchun'), findsOneWidget);
  });

  testWidgets('yuklanayotganda indikator chiqadi', (tester) async {
    await tester.pumpWidget(
      _wrap(
        RatesScreen(
          currencies: const [],
          isLoading: true,
          error: null,
          onRetry: () {},
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('xatoda "Qayta urinish" tugmasi ishlaydi', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _wrap(
        RatesScreen(
          currencies: const [],
          isLoading: false,
          error: 'Xato',
          onRetry: () => retried = true,
        ),
      ),
    );

    await tester.tap(find.text('Qayta urinish'));
    expect(retried, isTrue);
  });
}
