class Place {
  final String id;
  final String name;
  final String displayName;
  final double lat;
  final double lng;
  final String type; // 'stop', 'poi', 'station'

  const Place({
    required this.id,
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lng,
    this.type = 'poi',
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? json['name']?.toString() ?? '',
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: (json['lng'] ?? json['lon'] is num)
          ? ((json['lng'] ?? json['lon']) as num).toDouble()
          : double.tryParse((json['lng'] ?? json['lon'])?.toString() ?? '0') ?? 0.0,
      type: json['type']?.toString() ?? 'poi',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'display_name': displayName,
    'lat': lat,
    'lng': lng,
    'type': type,
  };
}
