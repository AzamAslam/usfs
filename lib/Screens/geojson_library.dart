import 'package:geojson_vi/geojson_vi.dart';

void main() {
  final featureCollection = GeoJSONFeatureCollection([]);
  final point = GeoJSONPoint([105.7743099, 21.0717561]);
  final feature = GeoJSONFeature(point, properties: {
    'marker-color': '#7e7e7e',
    'marker-size': 'medium',
    'marker-symbol': 'college',
    'title': 'Hanoi University of Mining and Geology',
    'department': 'Geoinformation Technology',
    'address':
    'No.18 Vien Street - Duc Thang Ward - Bac Tu Liem District - Ha Noi, Vietnam',
    'url': 'http://humg.edu.vn'
  });
  featureCollection.features.add(feature);
  final pos1 = [105.7771289, 21.0715458];
  final pos2 = [105.7745218, 21.0715658];
  final pos3 = [105.7729125, 21.0715358];
  final lineString = GeoJSONLineString([pos1, pos2, pos3]);
  featureCollection.features.add(GeoJSONFeature(lineString, properties: {
    'stroke': '#7e7e7e',
    'stroke-width': 2,
    'stroke-opacity': 1,
    'title': 'Vien St.'
  }));
  final p01 = [105.7739666, 21.0726795]; // The first position
  final p02 = [105.7739719, 21.0721991];
  final p03 = [105.7743394, 21.0721966];
  final p04 = [105.7743310, 21.0725269];
  final p05 = [105.7742564, 21.0726120];
  final p06 = [105.7741865, 21.0726095];
  final p07 = [105.7741785, 21.0726746];
  final p08 = [105.7739666, 21.0726795]; // The last position
  final linerRing = [p01, p02, p03, p04, p05, p06, p07, p08];
  featureCollection.features.add(
    GeoJSONFeature(
      GeoJSONPolygon([linerRing]),
      properties: {
        'stroke': '#555555',
        'stroke-width': 2,
        'stroke-opacity': 1,
        'fill': '#ab7942',
        'fill-opacity': 0.5,
        'title': "HUMG's Office"
      },
    ),
  );
  print(featureCollection.toJSON());
}