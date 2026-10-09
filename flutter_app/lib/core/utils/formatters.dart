import 'package:intl/intl.dart';

class AppFormatters {
  static String formatCurrency(num value) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(value);

  static String currency(num value) => formatCurrency(value);
}
