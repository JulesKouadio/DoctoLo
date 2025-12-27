import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/settings_service.dart';
import '../../core/constants/app_settings_constants.dart';
import '../../core/utils/size_config.dart';

/// Widget pour afficher un montant avec la devise configurée
class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showSymbol;

  const CurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.showSymbol = true,
  });

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();

    return ValueListenableBuilder(
      valueListenable: settingsService.currencyNotifier,
      builder: (context, currency, child) {
        return Text(
          showSymbol ? currency.format(amount) : amount.toStringAsFixed(2),
          style: style,
        );
      },
    );
  }
}

/// Extension pour faciliter le formatage de devise
extension CurrencyFormatting on num {
  String toCurrency() {
    return SettingsService().formatCurrency(toDouble());
  }
}

/// Widget pour sélectionner et afficher la devise
class CurrencyDisplay extends StatelessWidget {
  const CurrencyDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();

    return ValueListenableBuilder(
      valueListenable: settingsService.currencyNotifier,
      builder: (context, currency, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.money_dollar_circle,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '${currency.code} (${currency.symbol})',
              style: TextStyle(
                fontSize: getProportionateScreenHeight(14),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget pour afficher la langue actuelle
class LanguageDisplay extends StatelessWidget {
  const LanguageDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();

    return ValueListenableBuilder(
      valueListenable: settingsService.languageNotifier,
      builder: (context, language, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.globe, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              settingsService.currentLanguageName,
              style: TextStyle(
                fontSize: getProportionateScreenHeight(14),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget pour afficher l'icône ou le code de la devise actuelle
class CurrencyIcon extends StatelessWidget {
  final double? size;
  final Color? color;

  const CurrencyIcon({super.key, this.size, this.color});

  Widget _getCurrencyWidget(
    String currencyCode,
    double iconSize,
    Color? iconColor,
  ) {
    switch (currencyCode) {
      case 'EUR':
        return Icon(
          CupertinoIcons.money_euro,
          size: iconSize,
          color: iconColor,
        );
      case 'USD':
      case 'CAD':
        return Icon(
          CupertinoIcons.money_dollar,
          size: iconSize,
          color: iconColor,
        );
      case 'GBP':
        return Icon(
          CupertinoIcons.money_pound,
          size: iconSize,
          color: iconColor,
        );
      case 'CHF':
        return Text(
          'CHF',
          style: TextStyle(
            fontSize: iconSize * 0.6,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        );
      case 'MAD':
        return Text(
          'MAD',
          style: TextStyle(
            fontSize: iconSize * 0.6,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        );
      case 'TND':
        return Text(
          'TND',
          style: TextStyle(
            fontSize: iconSize * 0.6,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        );
      case 'DZD':
        return Text(
          'DZD',
          style: TextStyle(
            fontSize: iconSize * 0.6,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        );
      case 'XOF':
        return Text(
          'XOF',
          style: TextStyle(
            fontSize: iconSize * 0.6,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        );
      case 'XAF':
        return Text(
          'XAF',
          style: TextStyle(
            fontSize: iconSize * 0.6,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        );
      default:
        return Icon(
          CupertinoIcons.money_dollar_circle,
          size: iconSize,
          color: iconColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CurrencyInfo>(
      valueListenable: SettingsService().currencyNotifier,
      builder: (context, currency, child) {
        print('🔍 CurrencyIcon: code=${currency.code}');
        return _getCurrencyWidget(currency.code, size ?? 24, color);
      },
    );
  }
}
