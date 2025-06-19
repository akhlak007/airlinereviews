class Airport {
  final String code;
  final String name;

  const Airport({required this.code, required this.name});

  @override
  String toString() => '$code - $name';
}

class AirportList {
  static const List<Airport> airports = [
    Airport(code: "DAC", name: "Hazrat Shahjalal International, Dhaka"),
    Airport(code: "CGP", name: "Shah Amanat International, Chattogram"),
    Airport(code: "ZYL", name: "Osmani International, Sylhet"),
    Airport(code: "CXB", name: "Cox's Bazar International, Cox's Bazar"),
    Airport(code: "JSR", name: "Jessore Airport, Jessore"),
    Airport(code: "BZL", name: "Barisal Airport, Barisal"),
    Airport(code: "RJH", name: "Shah Makhdum Airport, Rajshahi"),
    Airport(code: "SPD", name: "Saidpur Airport, Saidpur"),
  ];
}