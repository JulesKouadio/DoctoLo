class AppSettingsConstants {
  // Langues disponibles
  static const Map<String, String> availableLanguages = {
    'fr': 'Français',
    'en': 'English',
    'es': 'Español',
    'ar': 'العربية',
    'de': 'Deutsch',
  };

  // Devises disponibles avec symboles
  static const Map<String, CurrencyInfo> availableCurrencies = {
    'EUR': CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    'USD': CurrencyInfo(code: 'USD', symbol: '\$', name: 'Dollar américain'),
    'GBP': CurrencyInfo(code: 'GBP', symbol: '£', name: 'Livre sterling'),
    'CHF': CurrencyInfo(code: 'CHF', symbol: 'CHF', name: 'Franc suisse'),
    'CAD': CurrencyInfo(code: 'CAD', symbol: 'C\$', name: 'Dollar canadien'),
    'MAD': CurrencyInfo(code: 'MAD', symbol: 'MAD', name: 'Dirham marocain'),
    'TND': CurrencyInfo(code: 'TND', symbol: 'TND', name: 'Dinar tunisien'),
    'DZD': CurrencyInfo(code: 'DZD', symbol: 'DZD', name: 'Dinar algérien'),
    'XOF': CurrencyInfo(code: 'XOF', symbol: 'CFA', name: 'Franc CFA'),
    'XAF': CurrencyInfo(code: 'XAF', symbol: 'FCFA', name: 'Franc CFA (BEAC)'),
  };

  // Valeurs par défaut
  static const String defaultLanguage = 'fr';
  static const String defaultCurrency = 'XOF';

  // Clés de stockage
  static const String languageKey = 'app_language';
  static const String currencyKey = 'app_currency';
}

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });

  String format(double amount) {
    final formattedAmount = amount.toStringAsFixed(2);
    return '$formattedAmount $symbol';
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'symbol': symbol, 'name': name};
  }

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) {
    return CurrencyInfo(
      code: json['code'] ?? 'EUR',
      symbol: json['symbol'] ?? '€',
      name: json['name'] ?? 'Euro',
    );
  }
}
