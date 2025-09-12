import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/currency.dart';
import '../models/exchange_rate.dart';
import '../data/currencies.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../widgets/currency_dropdown.dart';
import '../widgets/loading_widget.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  Currency? _fromCurrency;
  Currency? _toCurrency;
  ExchangeRate? _currentRate;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initializeCurrencies();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _initializeCurrencies() {
    setState(() {
      _fromCurrency = CurrencyData.getCurrencyByCode('USD');
      _toCurrency = CurrencyData.getCurrencyByCode('EUR');
    });
    _checkFavoriteStatus();
  }

  void _onAmountChanged() {
    if (_fromCurrency != null && _toCurrency != null && _amountController.text.isNotEmpty) {
      _fetchExchangeRate();
    }
  }

  Future<void> _fetchExchangeRate() async {
    if (_fromCurrency == null || _toCurrency == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rate = await ApiService.getExchangeRate(
        _fromCurrency!.code,
        _toCurrency!.code,
      );
      
      setState(() {
        _currentRate = rate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_fromCurrency != null && _toCurrency != null) {
      final pair = CurrencyPair(from: _fromCurrency!, to: _toCurrency!);
      final isFav = await FavoritesService.isFavorite(pair);
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _checkFavoriteStatus();
    if (_amountController.text.isNotEmpty) {
      _fetchExchangeRate();
    }
  }

  Future<void> _toggleFavorite() async {
    if (_fromCurrency == null || _toCurrency == null) return;

    final pair = CurrencyPair(from: _fromCurrency!, to: _toCurrency!);
    
    if (_isFavorite) {
      await FavoritesService.removeFavorite(pair);
    } else {
      await FavoritesService.addFavorite(pair);
    }
    
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getConvertedAmount() {
    if (_currentRate == null || _amountController.text.isEmpty) {
      return '0.00';
    }

    try {
      final amount = double.parse(_amountController.text);
      final convertedAmount = amount * _currentRate!.rate;
      return convertedAmount.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_fromCurrency != null && _toCurrency != null)
            IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Input Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Currency Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CurrencyDropdown(
                        selectedCurrency: _fromCurrency,
                        currencies: CurrencyData.currencies,
                        onChanged: (currency) {
                          setState(() {
                            _fromCurrency = currency;
                          });
                          _checkFavoriteStatus();
                          if (_amountController.text.isNotEmpty) {
                            _fetchExchangeRate();
                          }
                        },
                        hint: 'Select currency',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_horiz),
                  style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'To',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CurrencyDropdown(
                        selectedCurrency: _toCurrency,
                        currencies: CurrencyData.currencies,
                        onChanged: (currency) {
                          setState(() {
                            _toCurrency = currency;
                          });
                          _checkFavoriteStatus();
                          if (_amountController.text.isNotEmpty) {
                            _fetchExchangeRate();
                          }
                        },
                        hint: 'Select currency',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Conversion Result
            if (_isLoading)
              const LoadingWidget(message: 'Fetching exchange rate...')
            else if (_errorMessage != null)
              CustomErrorWidget(
                message: _errorMessage!,
                onRetry: _fetchExchangeRate,
              )
            else if (_currentRate != null && _amountController.text.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_fromCurrency?.flag} ${_amountController.text} ${_fromCurrency?.code}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_toCurrency?.flag} ${_getConvertedAmount()} ${_toCurrency?.code}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rate: 1 ${_fromCurrency?.code} = ${_currentRate!.rate.toStringAsFixed(4)} ${_toCurrency?.code}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _amountController.text.isEmpty ? null : _fetchExchangeRate,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Rate'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _amountController.clear();
                      setState(() {
                        _currentRate = null;
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
