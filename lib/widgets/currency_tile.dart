import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../utils/formatters.dart';

/// Ro'yxatdagi bitta qator: kod, nom va kurs.
class CurrencyTile extends StatelessWidget {
  const CurrencyTile({super.key, required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          currency.code,
          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(currency.nameUz),
      subtitle: Text('${currency.nominal} ${currency.code}'),
      trailing: Text(
        "${formatRate(currency.rate)} so'm",
        style: textTheme.titleMedium,
      ),
    );
  }
}
