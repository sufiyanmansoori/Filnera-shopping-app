import 'package:intl/intl.dart';
class CurrencyFormatter { static String format(num value) => NumberFormat.currency(locale: 'en_IN', symbol: '?', decimalDigits: 0).format(value); }
