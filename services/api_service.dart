import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_rate.dart';
import '../models/rate_history.dart';

class ApiService {
  static const String _baseUrl = 'https://api.frankfurter.app';
  
  /// Fetch current exchange rate between two currencies
  static Future<ExchangeRate> getExchangeRate(String from, String to) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/latest?from=$from&to=$to'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ExchangeRate.fromJson(data['rates'], from, to);
      } else {
        throw Exception('Failed to load exchange rate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch exchange rates for multiple currencies from a base currency
  static Future<Map<String, double>> getExchangeRates(String from, List<String> to) async {
    try {
      final toParam = to.join(',');
      final response = await http.get(
        Uri.parse('$_baseUrl/latest?from=$from&to=$toParam'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = <String, double>{};
        
        for (final entry in (data['rates'] as Map<String, dynamic>).entries) {
          rates[entry.key] = (entry.value as num).toDouble();
        }
        
        return rates;
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch historical exchange rates for the past 7 days
  static Future<RateHistory> getRateHistory(String from, String to) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final startDateStr = _formatDate(startDate);
      final endDateStr = _formatDate(endDate);
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$startDateStr..$endDateStr?from=$from&to=$to'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RateHistory.fromJson(data, from, to);
      } else {
        throw Exception('Failed to load rate history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get list of supported currencies
  static Future<List<String>> getSupportedCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/currencies'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as Map<String, dynamic>).keys.toList();
      } else {
        throw Exception('Failed to load supported currencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
