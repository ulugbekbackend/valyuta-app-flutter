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

const _gbp = Currency(
  code: 'GBP',
  nameUz: 'Angliya funt sterlingi',
  nameEn: 'Pound Sterling',
  nominal: 1,
  rate: 15548.54,
  diff: 12.5,
  date: '03.10.2026',
);

const _idr = Currency(
  code: 'IDR',
  nameUz: 'Indoneziya rupiyasi',
  nameEn: 'Indonesian Rupiah',
  nominal: 10,
  rate: 6.59,
  diff: 0,
  date: '03.10.2026',
);

/// RatesScreen'ni ota widgetsiz, soxta ma'lumot bilan chizadi.
Widget _screen({
  List<Currency> currencies = const [_usd, _gbp, _idr],
  bool isLoading = false,
  String? error,
  VoidCallback? onRetry,
  Future<void> Function()? onRefresh,
}) {
  return MaterialApp(
    home: Scaffold(
      body: RatesScreen(
        currencies: currencies,
        isLoading: isLoading,
        error: error,
        onRetry: onRetry ?? () {},
        onRefresh: onRefresh ?? () async {},
      ),
    ),
  );
}

void main() {
  testWidgets('ro\'yxat, sana va o\'zgarishlar ko\'rinadi', (tester) async {
    await tester.pumpWidget(_screen());

    expect(find.text('Oxirgi yangilanish: 03.10.2026'), findsOneWidget);
    expect(find.text('1 AQSH dollari'), findsOneWidget); // taxtada
    expect(
      find.textContaining('11 772,95', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('10 IDR uchun'), findsOneWidget);
    expect(find.text('▼ 35,81'), findsOneWidget); // USD tushgan
    expect(find.text('▲ 12,50'), findsOneWidget); // GBP o'sgan
    expect(find.text('0,00'), findsOneWidget); // IDR o'zgarmagan
  });

  testWidgets('qidiruv ro\'yxatni filtrlaydi', (tester) async {
    await tester.pumpWidget(_screen());

    await tester.enterText(find.byType(TextField), 'funt');
    await tester.pump();

    expect(find.text('Angliya funt sterlingi'), findsOneWidget);
    expect(find.text('Indoneziya rupiyasi'), findsNothing);
    expect(find.text('1 AQSH dollari'), findsNothing); // taxta yashirinadi
  });

  testWidgets('topilmasa xabar va tozalash tugmasi', (tester) async {
    await tester.pumpWidget(_screen());

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump();
    expect(find.textContaining('hech narsa topilmadi'), findsOneWidget);

    await tester.tap(find.text('Qidiruvni tozalash'));
    await tester.pump();
    expect(
      find.text('1 AQSH dollari'),
      findsOneWidget,
    ); // to'liq ro'yxat qaytdi
  });

  testWidgets('pastga tortilsa onRefresh chaqiriladi', (tester) async {
    var refreshed = false;
    await tester.pumpWidget(_screen(onRefresh: () async => refreshed = true));

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(refreshed, isTrue);
  });

  testWidgets('yuklanayotganda indikator chiqadi', (tester) async {
    await tester.pumpWidget(_screen(currencies: const [], isLoading: true));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('xatoda "Qayta urinish" tugmasi ishlaydi', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _screen(
        currencies: const [],
        error: 'Xato',
        onRetry: () => retried = true,
      ),
    );

    await tester.tap(find.text('Qayta urinish'));
    expect(retried, isTrue);
  });

  testWidgets('ma\'lumot bo\'sh bo\'lsa xabar chiqadi', (tester) async {
    await tester.pumpWidget(_screen(currencies: const []));

    expect(find.text("Hozircha kurslar yo'q."), findsOneWidget);
  });
}
