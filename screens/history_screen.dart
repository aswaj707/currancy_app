import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/currency.dart';
import '../models/rate_history.dart';
import '../data/currencies.dart';
import '../services/api_service.dart';
import '../widgets/currency_dropdown.dart';
import '../widgets/loading_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Currency? _fromCurrency;
  Currency? _toCurrency;
  RateHistory? _rateHistory;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCurrencies();
  }

  void _initializeCurrencies() {
    setState(() {
      _fromCurrency = CurrencyData.getCurrencyByCode('USD');
      _toCurrency = CurrencyData.getCurrencyByCode('EUR');
    });
    _fetchRateHistory();
  }

  Future<void> _fetchRateHistory() async {
    if (_fromCurrency == null || _toCurrency == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final history = await ApiService.getRateHistory(
        _fromCurrency!.code,
        _toCurrency!.code,
      );
      
      setState(() {
        _rateHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _fetchRateHistory();
  }

  List<FlSpot> _getChartData() {
    if (_rateHistory == null) return [];
    
    final sortedRates = _rateHistory!.sortedRates;
    return sortedRates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  double _getMinRate() {
    if (_rateHistory == null) return 0;
    final rates = _rateHistory!.rates.values.toList();
    return rates.reduce((a, b) => a < b ? a : b) * 0.99;
  }

  double _getMaxRate() {
    if (_rateHistory == null) return 1;
    final rates = _rateHistory!.rates.values.toList();
    return rates.reduce((a, b) => a > b ? a : b) * 1.01;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Currency Selection
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
                                  _fetchRateHistory();
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
                                  _fetchRateHistory();
                                },
                                hint: 'Select currency',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchRateHistory,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Chart Section
            if (_isLoading)
              const LoadingWidget(message: 'Loading rate history...')
            else if (_errorMessage != null)
              CustomErrorWidget(
                message: _errorMessage!,
                onRetry: _fetchRateHistory,
              )
            else if (_rateHistory != null)
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_fromCurrency?.flag} ${_fromCurrency?.code} to ${_toCurrency?.flag} ${_toCurrency?.code}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '7 days',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: (_getMaxRate() - _getMinRate()) / 5,
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    if (value.toInt() < _rateHistory!.sortedRates.length) {
                                      final date = _rateHistory!.sortedRates[value.toInt()].key;
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          _formatDate(date),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: (_getMaxRate() - _getMinRate()) / 5,
                                  reservedSize: 40,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        value.toStringAsFixed(4),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            minX: 0,
                            maxX: (_rateHistory!.sortedRates.length - 1).toDouble(),
                            minY: _getMinRate(),
                            maxY: _getMaxRate(),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _getChartData(),
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                  ],
                                ),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Rate Statistics
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Rate Statistics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard(
                                  'Highest',
                                  _rateHistory!.rates.values.reduce((a, b) => a > b ? a : b).toStringAsFixed(4),
                                  Colors.green,
                                ),
                                _buildStatCard(
                                  'Lowest',
                                  _rateHistory!.rates.values.reduce((a, b) => a < b ? a : b).toStringAsFixed(4),
                                  Colors.red,
                                ),
                                _buildStatCard(
                                  'Average',
                                  (_rateHistory!.rates.values.reduce((a, b) => a + b) / _rateHistory!.rates.length).toStringAsFixed(4),
                                  Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
