import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;

import 'models/currency.dart';
import 'screens/rates_screen.dart';
import 'services/currency_service.dart';
import 'utils/fonts.dart';
import 'widgets/rates_header.dart' show lapis;

Future<void> main() async {
  // runApp'dan oldin async ish qilish uchun Flutter'ni tayyorlaymiz.
  WidgetsFlutterBinding.ensureInitialized();
  await loadFonts();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valyuta kurslari',
      theme: _buildTheme(),
      // Web'da sichqoncha bilan ham ro'yxatni tortish (pull-to-refresh) mumkin.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      home: const HomePage(),
    );
  }
}

ThemeData _buildTheme() {
  final base = ThemeData(colorScheme: .fromSeed(seedColor: lapis));
  return base.copyWith(textTheme: appTextTheme(base.textTheme));
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

  /// Birinchi yuklash va "Qayta urinish": butun ekranda indikator.
  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _fetch();
  }

  /// Pull-to-refresh: ro'yxat joyida qoladi, faqat tepada indikator.
  Future<void> _refresh() => _fetch();

  Future<void> _fetch() async {
    try {
      final rates = await _service.fetchRates();
      if (!mounted) return; // ekran yopilgan bo'lsa setState chaqirilmaydi
      setState(() {
        _currencies = sortCurrencies(rates);
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Kurslarni yuklashda xato: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_currencies.isEmpty) {
        // Ko'rsatadigan hech narsa yo'q — xato ekrani.
        setState(() {
          _error = "Kurslarni yuklab bo'lmadi.\nInternet aloqasini tekshiring.";
        });
      } else {
        // Eski ma'lumot ekranda qoladi, pastda qisqa xabar.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Yangilab bo'lmadi. Internet aloqasini tekshiring."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Valyuta kurslari',
          style: displayFont(
            Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: RatesScreen(
        currencies: _currencies,
        isLoading: _isLoading,
        error: _error,
        onRetry: _loadRates,
        onRefresh: _refresh,
      ),
    );
  }
}
