import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatTravelDate(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}