import 'package:intl/intl.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(' ').map((str) => str.toCapitalized()).join(' ');
}

class DateHelper {
  /// Formatte une date en français sans initialisation de locale
  static String formatDateFr(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    // Si c'est aujourd'hui
    if (dateToCheck == today) {
      return "Aujourd'hui";
    }

    // Si c'est hier
    if (dateToCheck == yesterday) {
      return "Hier";
    }

    // Sinon, format personnalisé
    final months = [
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    return '${date.day} ${months[date.month]} ${date.year}';
  }

  /// Formatte un montant en XAF
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount)} XAF';
  }

  /// Formatte une heure
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Retourne une date relative (Il y a X jours)
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return "À l'instant";
        }
        return "Il y a ${difference.inMinutes} min";
      }
      return "Il y a ${difference.inHours}h";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "Il y a $weeks semaine${weeks > 1 ? 's' : ''}";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "Il y a $months mois";
    } else {
      final years = (difference.inDays / 365).floor();
      return "Il y a $years an${years > 1 ? 's' : ''}";
    }
  }
}

class AmountHelper {
  /// Formatte un montant avec séparateurs
  static String format(double amount, {String currency = 'XAF'}) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(amount)} $currency';
  }

  /// Retourne le montant avec signe (+ ou -)
  static String formatWithSign(
    double amount, {
    bool isIncome = false,
    String currency = 'XAF',
  }) {
    final sign = isIncome ? '+' : '-';
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '$sign ${formatter.format(amount.abs())} $currency';
  }
}
