import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;

import 'models/currency.dart';
import 'screens/converter_screen.dart';
import 'screens/rates_screen.dart';
import 'services/currency_service.dart';
import 'utils/fonts.dart';
import 'widgets/koshin.dart' show lapis;
import 'widgets/offline_banner.dart';

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
  /// [service] testlarda soxta servis berish uchun.
  const HomePage({super.key, this.service});

  final CurrencyService? service;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _service = widget.service ?? CurrencyService();

  List<Currency> _currencies = [];
  bool _isLoading = true;
  String? _error;
  int _tab = 0; // 0 — Kurslar, 1 — Konvertor

  /// Keshdagi ma'lumot ko'rsatilayotgan bo'lsa — qachon saqlangani.
  /// null — ma'lumot internetdan, yangi.
  DateTime? _offlineSince;

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
      final result = await _service.loadRates();
      if (!mounted) return; // ekran yopilgan bo'lsa setState chaqirilmaydi
      setState(() {
        _currencies = sortCurrencies(result.currencies);
        _offlineSince = result.fromCache ? result.savedAt : null;
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
          _tab == 0 ? 'Valyuta kurslari' : 'Konvertor',
          style: displayFont(
            Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Column(
        children: [
          // Offline bo'lsa — ikkala tab tepasida ham ko'rinadi.
          if (_offlineSince != null)
            OfflineBanner(savedAt: _offlineSince!, onRetry: _refresh),
          Expanded(
            // IndexedStack ikkala ekranni ham saqlab turadi, faqat bittasini
            // ko'rsatadi — tab almashganda qidiruv va summa yo'qolmaydi.
            child: IndexedStack(
              index: _tab,
              children: [
                RatesScreen(
                  currencies: _currencies,
                  isLoading: _isLoading,
                  error: _error,
                  onRetry: _loadRates,
                  onRefresh: _refresh,
                ),
                ConverterScreen(
                  currencies: _currencies,
                  isLoading: _isLoading,
                  onRetry: _loadRates,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Kurslar',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_exchange),
            label: 'Konvertor',
          ),
        ],
      ),
    );
  }
}
