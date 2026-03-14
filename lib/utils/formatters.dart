import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final DateFormat date = DateFormat('dd.MM.yyyy');
  static final DateFormat time = DateFormat('HH:mm');
  static final DateFormat month = DateFormat('MMMM yyyy', 'tr_TR');

  static String formatCurrency(double amount) {
    return currency.format(amount);
  }

  static String formatDate(DateTime dt) {
    return date.format(dt);
  }
}
