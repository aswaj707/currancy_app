import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_currency_pairs';

  /// Get all favorite currency pairs
  static Future<List<CurrencyPair>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      return favoritesJson
          .map((json) => CurrencyPair.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a currency pair to favorites
  static Future<bool> addFavorite(CurrencyPair pair) async {
    try {
      final favorites = await getFavorites();
      
      // Check if already exists
      if (favorites.any((fav) => fav.from.code == pair.from.code && fav.to.code == pair.to.code)) {
        return false;
      }
      
      favorites.add(pair);
      return await _saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  /// Remove a currency pair from favorites
  static Future<bool> removeFavorite(CurrencyPair pair) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((fav) => 
          fav.from.code == pair.from.code && fav.to.code == pair.to.code);
      return await _saveFavorites(favorites);
    } catch (e) {
      return false;
    }
  }

  /// Check if a currency pair is in favorites
  static Future<bool> isFavorite(CurrencyPair pair) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((fav) => 
          fav.from.code == pair.from.code && fav.to.code == pair.to.code);
    } catch (e) {
      return false;
    }
  }

  /// Clear all favorites
  static Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_favoritesKey);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _saveFavorites(List<CurrencyPair> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = favorites
          .map((pair) => jsonEncode(pair.toJson()))
          .toList();
      return await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      return false;
    }
  }
}

class CurrencyPair {
  final Currency from;
  final Currency to;

  const CurrencyPair({
    required this.from,
    required this.to,
  });

  factory CurrencyPair.fromJson(Map<String, dynamic> json) {
    return CurrencyPair(
      from: Currency(
        code: json['from']['code'],
        name: json['from']['name'],
        flag: json['from']['flag'],
        symbol: json['from']['symbol'],
      ),
      to: Currency(
        code: json['to']['code'],
        name: json['to']['name'],
        flag: json['to']['flag'],
        symbol: json['to']['symbol'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': {
        'code': from.code,
        'name': from.name,
        'flag': from.flag,
        'symbol': from.symbol,
      },
      'to': {
        'code': to.code,
        'name': to.name,
        'flag': to.flag,
        'symbol': to.symbol,
      },
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyPair && 
           other.from.code == from.code && 
           other.to.code == to.code;
  }

  @override
  int get hashCode => from.code.hashCode ^ to.code.hashCode;

  @override
  String toString() => '${from.code}/${to.code}';
}
