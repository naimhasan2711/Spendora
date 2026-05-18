import 'package:intl/intl.dart';

import '../services/hive_service.dart';

/// Format utilities for the app
class AppFormatters {
  AppFormatters._();

  /// Format currency amount with symbol
  static String formatCurrency(
    double amount, {
    String? currencyCode,
    bool showSymbol = true,
    bool showSign = false,
  }) {
    final code = currencyCode ?? 'BDT';
    final currency = HiveService.instance.currenciesBox.get(code);
    final symbol = currency?.symbol ?? '৳';

    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formatted = formatter.format(amount.abs());

    String result = showSymbol ? '$symbol$formatted' : formatted;

    if (showSign && amount != 0) {
      result = amount > 0 ? '+$result' : '-$result';
    } else if (amount < 0 && !showSign) {
      result = '-$result';
    }

    return result;
  }

  /// Format compact currency (e.g., 1.2K, 1.5M)
  static String formatCompactCurrency(double amount, {String? currencyCode}) {
    final code = currencyCode ?? 'BDT';
    final currency = HiveService.instance.currenciesBox.get(code);
    final symbol = currency?.symbol ?? '৳';

    final formatter = NumberFormat.compact();
    return '$symbol${formatter.format(amount)}';
  }

  /// Format date
  static String formatDate(DateTime date, {String? format}) {
    final settings = HiveService.instance.settings;
    final dateFormat = format ?? settings.dateFormat;
    return DateFormat(dateFormat).format(date);
  }

  /// Format time
  static String formatTime(DateTime time, {String? format}) {
    final settings = HiveService.instance.settings;
    final timeFormat = format ?? settings.timeFormat;
    return DateFormat(timeFormat).format(time);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Format relative date (Today, Yesterday, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // Day name
    } else if (dateOnly.year == now.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  /// Format month and year
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format number with commas
  static String formatNumber(num number, {int decimals = 0}) {
    final formatter =
        NumberFormat('#,##0${decimals > 0 ? '.${'0' * decimals}' : ''}');
    return formatter.format(number);
  }

  /// Parse currency string to double
  static double? parseCurrency(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.-]'), '');
    return double.tryParse(cleaned);
  }
}

/// Date helper utilities
class DateHelpers {
  DateHelpers._();

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week
  static DateTime startOfWeek(DateTime date, {int weekStartDay = 0}) {
    final daysToSubtract = (date.weekday - weekStartDay + 7) % 7;
    return startOfDay(date.subtract(Duration(days: daysToSubtract)));
  }

  /// Get end of week
  static DateTime endOfWeek(DateTime date, {int weekStartDay = 0}) {
    final start = startOfWeek(date, weekStartDay: weekStartDay);
    return endOfDay(start.add(const Duration(days: 6)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return endOfDay(DateTime(date.year, date.month + 1, 0));
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get end of year
  static DateTime endOfYear(DateTime date) {
    return endOfDay(DateTime(date.year, 12, 31));
  }

  /// Get number of days in month
  static int daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Check if same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if same month
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// Check if same year
  static bool isSameYear(DateTime a, DateTime b) {
    return a.year == b.year;
  }

  /// Get list of dates in range
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = startOfDay(start);
    final endDate = startOfDay(end);

    while (!current.isAfter(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  /// Get previous month
  static DateTime previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1, 1);
  }

  /// Get next month
  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }
}
