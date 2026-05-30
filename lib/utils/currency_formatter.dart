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
    final isNegative = amount < 0;
    final abs = amount.abs();
    String result;

    if (abs >= 1000000000) {
      final val = abs / 1000000000;
      // Truncate ke 1 desimal (tanpa pembulatan ke atas)
      final truncated = (val * 10).floor() / 10;
      result = '${truncated.toStringAsFixed(1)} M';
    } else if (abs >= 1000000) {
      final val = abs / 1000000;
      final truncated = (val * 10).floor() / 10;
      result = '${truncated.toStringAsFixed(1)} Jt';
    } else if (abs >= 1000) {
      final val = abs / 1000;
      final truncated = (val * 10).floor() / 10;
      result = '${truncated.toStringAsFixed(1)} Rb';
    } else {
      result = abs.toStringAsFixed(0);
    }

    return isNegative ? '-$result' : result;
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
