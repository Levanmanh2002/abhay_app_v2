import 'package:abhay_app_v2/resourese/service/localization_service.dart';
import 'package:abhay_app_v2/utils/app_enums.dart';
import 'package:intl/intl.dart';

extension CurrencyFormatter on num {
  String get formattedCurrency {
    final locale = LocalizationService.language.locale.languageCode;

    if (this % 1 == 0) {
      final format = NumberFormat.currency(locale: locale, symbol: '', decimalDigits: 0);
      return '\$${format.format(this)}';
    } else {
      final format = NumberFormat.currency(locale: locale, symbol: '', decimalDigits: 2);
      return '\$${format.format(this)}';
    }

    // final NumberFormat currencyFormat = NumberFormat.currency(
    //   locale: LocalizationService.language.locale.languageCode,
    //   symbol: '',
    //   decimalDigits: 2,
    // );
    // return '\$${currencyFormat.format(this).trim()}';
  }

  String get formattedWithoutCurrency {
    final NumberFormat currencyFormat = NumberFormat.decimalPattern(LocalizationService.language.locale.languageCode);
    return currencyFormat.format(this).trim();
  }

  static String get currencySymbol {
    final localeCode = LocalizationService.language.locale.toString();
    final currencyFormat = NumberFormat.simpleCurrency(locale: localeCode);
    return currencyFormat.currencySymbol;
  }
}
