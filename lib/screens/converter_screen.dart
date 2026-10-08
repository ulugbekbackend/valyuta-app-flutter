import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../utils/fonts.dart';
import '../utils/formatters.dart';
import '../widgets/koshin.dart';
import '../widgets/message_view.dart';

/// Konvertor: so'm ↔ tanlangan valyuta. Natija yozilayotganda darhol
/// hisoblanadi. Kurslarni ota widget (HomePage) beradi.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({
    super.key,
    required this.currencies,
    required this.isLoading,
    required this.onRetry,
  });

  final List<Currency> currencies;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _amountController = TextEditingController(text: '100');
  String _code = 'USD';

  /// true: valyuta → so'm (100 USD = ? so'm), false: so'm → valyuta.
  bool _toUzs = true;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Tanlangan valyuta. Ro'yxatda bo'lmasa (masalan yangilangandan keyin
  /// yo'qolgan bo'lsa) — birinchisi.
  Currency get _currency => widget.currencies.firstWhere(
    (c) => c.code == _code,
    orElse: () => widget.currencies.first,
  );

  void _swap() => setState(() => _toUzs = !_toUzs);

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.currencies.isEmpty) {
      return MessageView(
        icon: Icons.cloud_off,
        text:
            'Konvertor ishlashi uchun kurslar kerak.\n'
            'Internet aloqasini tekshiring.',
        action: FilledButton(
          onPressed: widget.onRetry,
          child: const Text('Qayta urinish'),
        ),
      );
    }

    final currency = _currency;
    final text = _amountController.text;
    final error = amountError(text);
    final amount = parseAmount(text);
    final result = amount == null
        ? null
        : (_toUzs ? currency.toUzs(amount) : currency.fromUzs(amount));

    final fromCode = _toUzs ? currency.code : 'UZS';
    final toCode = _toUzs ? 'UZS' : currency.code;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCurrencyPicker(),
            const SizedBox(height: 16),
            _buildAmountField(fromCode, error),
            const SizedBox(height: 8),
            Center(
              child: IconButton.filledTonal(
                tooltip: "Yo'nalishni almashtirish",
                icon: const Icon(Icons.swap_vert),
                iconSize: 28,
                onPressed: _swap,
              ),
            ),
            const SizedBox(height: 8),
            _buildResult(result, toCode),
            const SizedBox(height: 16),
            _buildRateInfo(currency),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyPicker() {
    return DropdownMenu<String>(
      key: ValueKey(
        widget.currencies.length,
      ), // ro'yxat yangilansa qayta quriladi
      initialSelection: _currency.code,
      label: const Text('Valyuta'),
      expandedInsets: EdgeInsets.zero, // to'liq kenglik
      menuHeight: 360,
      enableFilter: true, // yozib qidirish mumkin
      requestFocusOnTap: true,
      leadingIcon: const Icon(Icons.currency_exchange),
      // Summa maydoni bilan bir xil ko'rinish: to'ldirilgan fon, ramkasiz.
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownMenuEntries: [
        for (final c in widget.currencies)
          DropdownMenuEntry(value: c.code, label: '${c.code} — ${c.nameUz}'),
      ],
      onSelected: (code) {
        if (code != null) setState(() => _code = code);
      },
    );
  }

  Widget _buildAmountField(String fromCode, String? error) {
    return TextField(
      controller: _amountController,
      onChanged: (_) => setState(() {}), // har harfda natijani qayta hisoblash
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: bodyFont(
        Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      decoration: InputDecoration(
        labelText: 'Berasiz',
        suffixText: fromCode,
        errorText: error,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResult(double? result, String toCode) {
    final textTheme = Theme.of(context).textTheme;

    return KoshinPanel(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olasiz',
            style: textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: result == null ? '—' : formatRate(result),
                    style: displayFont(
                      textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  TextSpan(
                    text: ' $toCode',
                    style: displayFont(
                      textTheme.titleMedium?.copyWith(color: gold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateInfo(Currency currency) {
    final style = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${currency.nominal} ${currency.code} = "
            "${formatRate(currency.rate)} so'm",
            style: style,
          ),
          Text('Markaziy bank kursi, ${currency.date}', style: style),
        ],
      ),
    );
  }
}
