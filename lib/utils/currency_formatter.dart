import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatCurrency(double amount, {String symbol = 'Rp '}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)} Rb';
    }
    return amount.toStringAsFixed(0);
  }

  static double? parseCurrency(String value) {
    try {
      final cleanValue = value.replaceAll(RegExp(r'[Rp\s.]'), '').replaceAll(',', '.');
      return double.tryParse(cleanValue);
    } catch (e) {
      return null;
    }
  }
}
