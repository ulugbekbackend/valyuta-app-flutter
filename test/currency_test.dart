import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:valyuta_app/models/currency.dart';
import 'package:valyuta_app/services/currency_service.dart';

// CBU API'dan olingan haqiqiy namunalar (2026-10-03).
const usdJson = {
  'id': 68,
  'Code': '840',
  'Ccy': 'USD',
  'CcyNm_RU': 'Доллар США',
  'CcyNm_UZ': 'AQSH dollari',
  'CcyNm_UZC': 'АҚШ доллари',
  'CcyNm_EN': 'US Dollar',
  'Nominal': '1',
  'Rate': '11772.95',
  'Diff': '-35.81',
  'Date': '03.10.2026',
};

const idrJson = {
  'Ccy': 'IDR',
  'CcyNm_UZ': 'Indoneziya rupiyasi',
  'CcyNm_EN': 'Indonesian Rupiah',
  'Nominal': '10',
  'Rate': '6.59',
  'Diff': '-0.02',
  'Date': '03.10.2026',
};

void main() {
  group('Currency.fromJson', () {
    test('USD ni to\'g\'ri parse qiladi', () {
      final usd = Currency.fromJson(usdJson);

      expect(usd.code, 'USD');
      expect(usd.nameUz, 'AQSH dollari');
      expect(usd.nameEn, 'US Dollar');
      expect(usd.nominal, 1);
      expect(usd.rate, 11772.95);
      expect(usd.diff, -35.81);
      expect(usd.date, '03.10.2026');
      expect(usd.ratePerUnit, 11772.95);
    });

    test('Nominal=10 bo\'lsa 1 birlik narxini hisoblaydi', () {
      final idr = Currency.fromJson(idrJson);

      expect(idr.nominal, 10);
      expect(idr.rate, 6.59);
      expect(idr.ratePerUnit, closeTo(0.659, 1e-9));
    });

    test('noto\'g\'ri yoki bo\'sh qiymatlarda yiqilmaydi', () {
      final broken = Currency.fromJson({
        'Ccy': 'XXX',
        'Nominal': '',
        'Rate': 'abc',
        'Diff': null,
      });

      expect(broken.code, 'XXX');
      expect(broken.nameUz, '');
      expect(broken.nominal, 1);
      expect(broken.rate, 0);
      expect(broken.diff, 0);
      expect(broken.date, '');
    });

    test('Nominal=0 bo\'lsa 1 deb oladi (nolga bo\'linmaslik uchun)', () {
      final c = Currency.fromJson({'Ccy': 'XXX', 'Nominal': '0', 'Rate': '5'});
      expect(c.nominal, 1);
      expect(c.ratePerUnit, 5);
    });
  });

  group('CurrencyService.fetchRates', () {
    test('200 javobni ro\'yxatga aylantiradi', () async {
      final client = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(jsonEncode([usdJson, idrJson])),
          200,
        );
      });

      final rates = await CurrencyService(client: client).fetchRates();

      expect(rates.length, 2);
      expect(rates.first.code, 'USD');
      expect(rates.last.nominal, 10);
    });

    test('server xatosida exception tashlaydi', () async {
      final client = MockClient((request) async => http.Response('', 500));

      expect(
        CurrencyService(client: client).fetchRates(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
