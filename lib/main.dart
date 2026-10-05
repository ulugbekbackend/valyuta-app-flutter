import 'package:flutter/material.dart';

import 'models/currency.dart';
import 'screens/rates_screen.dart';
import 'services/currency_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valyuta kurslari',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: const HomePage(),
    );
  }
}

/// Ma'lumot (ro'yxat, yuklanish, xato) shu yerda saqlanadi va
/// ekranlarga constructor orqali uzatiladi ("lifting state up").
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = CurrencyService();

  List<Currency> _currencies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRates(); // ekran birinchi marta ochilganda (React: useEffect(..., []))
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rates = await _service.fetchRates();
      if (!mounted) return; // ekran yopilgan bo'lsa setState chaqirilmaydi
      setState(() {
        _currencies = sortCurrencies(rates);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Kurslarni yuklashda xato: $e');
      if (!mounted) return;
      setState(() {
        _error = "Kurslarni yuklab bo'lmadi.\nInternet aloqasini tekshiring.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Valyuta kurslari')),
      body: RatesScreen(
        currencies: _currencies,
        isLoading: _isLoading,
        error: _error,
        onRetry: _loadRates,
      ),
    );
  }
}
