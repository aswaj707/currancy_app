class ExchangeRate {
  final String base;
  final String target;
  final double rate;
  final DateTime timestamp;

  const ExchangeRate({
    required this.base,
    required this.target,
    required this.rate,
    required this.timestamp,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json, String base, String target) {
    return ExchangeRate(
      base: base,
      target: target,
      rate: (json[target] as num).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'target': target,
      'rate': rate,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() => '$base/$target: $rate';
}
