class RateHistory {
  final String base;
  final String target;
  final Map<String, double> rates;
  final DateTime startDate;
  final DateTime endDate;

  const RateHistory({
    required this.base,
    required this.target,
    required this.rates,
    required this.startDate,
    required this.endDate,
  });

  factory RateHistory.fromJson(Map<String, dynamic> json, String base, String target) {
    final rates = <String, double>{};
    final dates = json['rates'] as Map<String, dynamic>;
    
    for (final entry in dates.entries) {
      final date = entry.key;
      final rateData = entry.value as Map<String, dynamic>;
      if (rateData.containsKey(target)) {
        rates[date] = (rateData[target] as num).toDouble();
      }
    }

    return RateHistory(
      base: base,
      target: target,
      rates: rates,
      startDate: DateTime.parse(rates.keys.first),
      endDate: DateTime.parse(rates.keys.last),
    );
  }

  List<MapEntry<DateTime, double>> get sortedRates {
    final entries = rates.entries
        .map((e) => MapEntry(DateTime.parse(e.key), e.value))
        .toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  @override
  String toString() => '$base/$target: ${rates.length} days of data';
}
