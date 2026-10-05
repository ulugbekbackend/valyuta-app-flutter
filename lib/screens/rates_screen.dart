import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../services/currency_service.dart';
import '../utils/fonts.dart';
import '../widgets/currency_tile.dart';
import '../widgets/message_view.dart';
import '../widgets/rates_header.dart';

/// Kurslar ro'yxati. Ma'lumotni o'zi yuklamaydi — ota widget (HomePage)
/// beradi. Bu ekranning o'z holati faqat qidiruv matni.
class RatesScreen extends StatefulWidget {
  const RatesScreen({
    super.key,
    required this.currencies,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onRefresh,
  });

  final List<Currency> currencies;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  /// Pull-to-refresh: tugaguncha aylanuvchi indikator ko'rinib turadi.
  final Future<void> Function() onRefresh;

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  // TextField'ni boshqarish uchun (React: useRef + controlled input).
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController
        .dispose(); // xotirani bo'shatish (React: useEffect cleanup)
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.error != null) {
      return MessageView(
        icon: Icons.cloud_off,
        text: widget.error!,
        action: FilledButton(
          onPressed: widget.onRetry,
          child: const Text('Qayta urinish'),
        ),
      );
    }

    if (widget.currencies.isEmpty) {
      return MessageView(
        icon: Icons.inbox_outlined,
        text: "Hozircha kurslar yo'q.",
        action: FilledButton(
          onPressed: widget.onRetry,
          child: const Text('Yangilash'),
        ),
      );
    }

    // Keng ekranda (desktop) cho'zilib ketmasligi uchun eni cheklanadi.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _buildSearchField(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: widget.onRefresh,
                child: _query.trim().isEmpty
                    ? _buildFullList()
                    : _buildSearchResults(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Valyuta qidirish: USD, dollar, rubl…',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Tozalash',
                icon: const Icon(Icons.close),
                onPressed: _clearSearch,
              ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Qidiruv bo'sh: sana + taxta (USD/EUR/RUB) + qolgan valyutalar.
  Widget _buildFullList() {
    final currencies = widget.currencies;
    final pinned = currencies
        .where((c) => pinnedCodes.contains(c.code))
        .toList();
    final others = currencies
        .where((c) => !pinnedCodes.contains(c.code))
        .toList();
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ListView.separated(
      // ro'yxat qisqa bo'lsa ham pastga tortib yangilash ishlashi uchun
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: others.length + 1, // +1: birinchi element — tepa qism
      separatorBuilder: (context, index) => index == 0
          ? const SizedBox.shrink()
          : const Divider(height: 1, indent: 24, endIndent: 24),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                child: Text(
                  'Oxirgi yangilanish: ${currencies.first.date}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              RatesHeader(pinned: pinned),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                child: Text(
                  'Boshqa valyutalar',
                  style: bodyFont(
                    textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return CurrencyTile(currency: others[index - 1]);
      },
    );
  }

  /// Qidiruv bor: barcha valyutalar ichidan mosini oddiy ro'yxatda.
  Widget _buildSearchResults() {
    final results = filterCurrencies(widget.currencies, _query);

    if (results.isEmpty) {
      // ListView — bo'sh natijada ham pastga tortib yangilash ishlasin.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 48),
          MessageView(
            icon: Icons.search_off,
            text: "“${_query.trim()}” bo'yicha hech narsa topilmadi.",
            action: TextButton(
              onPressed: _clearSearch,
              child: const Text('Qidiruvni tozalash'),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: results.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 24, endIndent: 24),
      itemBuilder: (context, index) => CurrencyTile(currency: results[index]),
    );
  }
}
