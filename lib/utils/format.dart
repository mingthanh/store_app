import 'package:intl/intl.dart';

/// Format a number as Vietnamese Dong currency.
/// Examples:
///  - 120000 -> 120.000 ₫
///  - 120000.5 -> 120.001 ₫ (rounded)
String formatCurrencyVND(num? amount) {
  final value = (amount ?? 0).toDouble();
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  return formatter.format(value);
}

/// Format a compact number with Vietnamese locale (e.g., 1200 -> 1,2 N).
String formatCompactVi(num? number) {
  final value = (number ?? 0).toDouble();
  return NumberFormat.compact(locale: 'vi_VN').format(value);
}
