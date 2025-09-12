class Currency {
  final String code;
  final String name;
  final String flag;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.flag,
    required this.symbol,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code - $name';
}
