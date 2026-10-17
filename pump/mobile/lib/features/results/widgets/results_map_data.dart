import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../theme/marg_tokens.dart';
import '../../../data/models/route_model.dart';
import '../../../data/models/place.dart';

abstract final class ResultsMapData {
  static List<LatLng> getAllPoints(TransitRoute route) {
    if (route.routeId == 'r_transfers') {
      return const [
        LatLng(18.5074, 73.8077), LatLng(18.5126, 73.8291), LatLng(18.5182, 73.8413),
        LatLng(18.5284, 73.8744), LatLng(18.5529, 73.8797), LatLng(18.5679, 73.9143),
      ];
    }
    return const [
      LatLng(18.5074, 73.8077), LatLng(18.5098, 73.8180), LatLng(18.5182, 73.8413),
      LatLng(18.5308, 73.8475), LatLng(18.5529, 73.8797), LatLng(18.5679, 73.9143),
    ];
  }

  static List<Polyline> buildPolylines(TransitRoute route, double opacity, MargColors c, Place from, Place to) {
    final walkPts = [LatLng(from.lat, from.lng), const LatLng(18.5098, 73.8180)];
    final busPts = route.routeId == 'r_transfers'
        ? const [
            LatLng(18.5126, 73.8291), LatLng(18.5182, 73.8413), LatLng(18.5284, 73.8744),
            LatLng(18.5529, 73.8797), LatLng(18.5670, 73.9130),
          ]
        : const [
            LatLng(18.5098, 73.8180), LatLng(18.5182, 73.8413), LatLng(18.5308, 73.8475),
            LatLng(18.5529, 73.8797), LatLng(18.5670, 73.9130),
          ];
    final endWalkPts = [const LatLng(18.5670, 73.9130), LatLng(to.lat, to.lng)];

    return [
      Polyline(points: walkPts, strokeWidth: 4, color: c.gray.withValues(alpha: opacity), pattern: const StrokePattern.dotted(spacingFactor: 1.5)),
      Polyline(points: busPts, strokeWidth: 8, color: c.card.withValues(alpha: opacity)),
      Polyline(points: busPts, strokeWidth: 5, color: c.blue.withValues(alpha: opacity)),
      Polyline(points: endWalkPts, strokeWidth: 4, color: c.gray.withValues(alpha: opacity), pattern: const StrokePattern.dotted(spacingFactor: 1.5)),
    ];
  }
}
