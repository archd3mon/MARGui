class StopEta {
  final String route;
  final int mins;

  const StopEta({required this.route, required this.mins});

  factory StopEta.fromJson(Map<String, dynamic> json) => StopEta(
        route: json['route']?.toString() ?? '',
        mins: (json['mins'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {'route': route, 'mins': mins};
}

class TransitStop {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String type; // 'bus' | 'metro'
  final String subtext;
  final int distanceMeters;
  final List<StopEta> etas;

  const TransitStop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.type = 'bus',
    this.subtext = '',
    this.distanceMeters = 0,
    this.etas = const [],
  });

  factory TransitStop.fromJson(Map<String, dynamic> json) {
    final etasRaw = json['etas'] as List<dynamic>? ?? [];
    return TransitStop(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: (json['lng'] ?? json['lon'] is num)
          ? ((json['lng'] ?? json['lon']) as num).toDouble()
          : double.tryParse((json['lng'] ?? json['lon'])?.toString() ?? '0') ?? 0.0,
      type: json['type']?.toString() ?? 'bus',
      subtext: json['subtext']?.toString() ?? '',
      distanceMeters: (json['distance_meters'] as num?)?.toInt() ?? 0,
      etas: etasRaw.map((e) => StopEta.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lat': lat,
    'lng': lng,
    'type': type,
    'subtext': subtext,
    'distance_meters': distanceMeters,
    'etas': etas.map((e) => e.toJson()).toList(),
  };
}
