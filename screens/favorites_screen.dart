import 'package:flutter/material.dart';
import '../models/exchange_rate.dart';
import '../services/favorites_service.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<CurrencyPair> _favorites = [];
  Map<String, ExchangeRate> _rates = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final favorites = await FavoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
      
      if (favorites.isNotEmpty) {
        _fetchAllRates();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAllRates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rates = <String, ExchangeRate>{};
      
      for (final pair in _favorites) {
        try {
          final rate = await ApiService.getExchangeRate(
            pair.from.code,
            pair.to.code,
          );
          rates['${pair.from.code}_${pair.to.code}'] = rate;
        } catch (e) {
          // Continue with other pairs if one fails
          // Log error for debugging
        }
      }
      
      setState(() {
        _rates = rates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(CurrencyPair pair) async {
    try {
      await FavoritesService.removeFavorite(pair);
      setState(() {
        _favorites.removeWhere((fav) => 
            fav.from.code == pair.from.code && fav.to.code == pair.to.code);
        _rates.remove('${pair.from.code}_${pair.to.code}');
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text('Are you sure you want to remove all favorite currency pairs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FavoritesService.clearFavorites();
        setState(() {
          _favorites.clear();
          _rates.clear();
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All favorites cleared'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear favorites: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  String _getRateForPair(CurrencyPair pair) {
    final rateKey = '${pair.from.code}_${pair.to.code}';
    final rate = _rates[rateKey];
    return rate?.rate.toStringAsFixed(4) ?? 'Loading...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              onPressed: _fetchAllRates,
              icon: const Icon(Icons.refresh),
            ),
          if (_favorites.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') {
                  _clearAllFavorites();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading && _favorites.isEmpty
          ? const LoadingWidget(message: 'Loading favorites...')
          : _errorMessage != null && _favorites.isEmpty
              ? CustomErrorWidget(
                  message: _errorMessage!,
                  onRetry: _loadFavorites,
                )
              : _favorites.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorites Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add currency pairs to your favorites from the converter screen to see them here.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to converter screen
                // This would need to be handled by the parent widget
              },
              icon: const Icon(Icons.currency_exchange),
              label: const Text('Go to Converter'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return Column(
      children: [
        if (_isLoading)
          const LinearProgressIndicator(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final pair = _favorites[index];
              final rate = _getRateForPair(pair);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pair.from.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        pair.to.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  title: Text(
                    '${pair.from.code} → ${pair.to.code}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pair.from.name} to ${pair.to.name}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          '1 ${pair.from.code} = $rate ${pair.to.code}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _removeFavorite(pair),
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    tooltip: 'Remove from favorites',
                  ),
                  onTap: () {
                    // Navigate to converter with this pair
                    // This would need to be handled by the parent widget
                    // You could also pass the pair to the converter screen
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
