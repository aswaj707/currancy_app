import '../models/currency.dart';

class CurrencyData {
  static const List<Currency> currencies = [
    Currency(
      code: 'USD',
      name: 'US Dollar',
      flag: '🇺🇸',
      symbol: '\$',
    ),
    Currency(
      code: 'EUR',
      name: 'Euro',
      flag: '🇪🇺',
      symbol: '€',
    ),
    Currency(
      code: 'GBP',
      name: 'British Pound',
      flag: '🇬🇧',
      symbol: '£',
    ),
    Currency(
      code: 'JPY',
      name: 'Japanese Yen',
      flag: '🇯🇵',
      symbol: '¥',
    ),
    Currency(
      code: 'AUD',
      name: 'Australian Dollar',
      flag: '🇦🇺',
      symbol: 'A\$',
    ),
    Currency(
      code: 'CAD',
      name: 'Canadian Dollar',
      flag: '🇨🇦',
      symbol: 'C\$',
    ),
    Currency(
      code: 'CHF',
      name: 'Swiss Franc',
      flag: '🇨🇭',
      symbol: 'CHF',
    ),
    Currency(
      code: 'CNY',
      name: 'Chinese Yuan',
      flag: '🇨🇳',
      symbol: '¥',
    ),
    Currency(
      code: 'INR',
      name: 'Indian Rupee',
      flag: '🇮🇳',
      symbol: '₹',
    ),
    Currency(
      code: 'BRL',
      name: 'Brazilian Real',
      flag: '🇧🇷',
      symbol: 'R\$',
    ),
    Currency(
      code: 'RUB',
      name: 'Russian Ruble',
      flag: '🇷🇺',
      symbol: '₽',
    ),
    Currency(
      code: 'KRW',
      name: 'South Korean Won',
      flag: '🇰🇷',
      symbol: '₩',
    ),
    Currency(
      code: 'MXN',
      name: 'Mexican Peso',
      flag: '🇲🇽',
      symbol: '\$',
    ),
    Currency(
      code: 'SGD',
      name: 'Singapore Dollar',
      flag: '🇸🇬',
      symbol: 'S\$',
    ),
    Currency(
      code: 'HKD',
      name: 'Hong Kong Dollar',
      flag: '🇭🇰',
      symbol: 'HK\$',
    ),
    Currency(
      code: 'NZD',
      name: 'New Zealand Dollar',
      flag: '🇳🇿',
      symbol: 'NZ\$',
    ),
    Currency(
      code: 'SEK',
      name: 'Swedish Krona',
      flag: '🇸🇪',
      symbol: 'kr',
    ),
    Currency(
      code: 'NOK',
      name: 'Norwegian Krone',
      flag: '🇳🇴',
      symbol: 'kr',
    ),
    Currency(
      code: 'DKK',
      name: 'Danish Krone',
      flag: '🇩🇰',
      symbol: 'kr',
    ),
    Currency(
      code: 'PLN',
      name: 'Polish Zloty',
      flag: '🇵🇱',
      symbol: 'zł',
    ),
    Currency(
      code: 'TRY',
      name: 'Turkish Lira',
      flag: '🇹🇷',
      symbol: '₺',
    ),
    Currency(
      code: 'ZAR',
      name: 'South African Rand',
      flag: '🇿🇦',
      symbol: 'R',
    ),
    Currency(
      code: 'AED',
      name: 'UAE Dirham',
      flag: '🇦🇪',
      symbol: 'د.إ',
    ),
    Currency(
      code: 'SAR',
      name: 'Saudi Riyal',
      flag: '🇸🇦',
      symbol: 'ر.س',
    ),
    Currency(
      code: 'THB',
      name: 'Thai Baht',
      flag: '🇹🇭',
      symbol: '฿',
    ),
  ];

  static Currency? getCurrencyByCode(String code) {
    try {
      return currencies.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<Currency> getPopularCurrencies() {
    const popularCodes = ['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'INR'];
    return currencies.where((currency) => popularCodes.contains(currency.code)).toList();
  }
}
