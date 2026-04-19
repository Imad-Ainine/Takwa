import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class Mosque {
  final int id;
  final String name;
  final double lat;
  final double lon;
  final double distance; // in meters
  final String address;
  final String phone;

  Mosque({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.distance,
    this.address = 'بدون عنوان محدد',
    this.phone = '',
  });
}

class MosqueRepository {
  static const List<String> _overpassUrls = [
    'https://overpass-api.de/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
    'https://z.overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  Future<List<Mosque>> fetchNearbyMosques(
    Position position, {
    double radius = 5000,
  }) async {
    final query =
        '''
      [out:json];
      nwr["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,${position.latitude},${position.longitude});
      out center;
    ''';

    for (final url in _overpassUrls) {
      try {
        final response = await http
            .post(Uri.parse(url), body: {'data': query})
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final decoded = json.decode(utf8.decode(response.bodyBytes));
          final elements = decoded['elements'] as List;

          List<Mosque> mosques = elements
              .map<Mosque?>((e) {
                if (e['type'] == 'node' ||
                    e['type'] == 'way' ||
                    e['type'] == 'relation') {
                  final tags = e['tags'] ?? {};
                  final lat = e['lat'] ?? e['center']?['lat'];
                  final lon = e['lon'] ?? e['center']?['lon'];

                  if (lat == null || lon == null) return null;
                  final name = tags['name'] ?? tags['name:ar'] ?? 'مسجد قريب';

                  final address =
                      tags['addr:full'] ??
                      tags['addr:street'] ??
                      'بدون عنوان محدد';
                  final phone = tags['contact:phone'] ?? tags['phone'] ?? '';

                  final distance = Geolocator.distanceBetween(
                    position.latitude,
                    position.longitude,
                    lat,
                    lon,
                  );

                  return Mosque(
                    id: e['id'],
                    name: name,
                    lat: lat,
                    lon: lon,
                    distance: distance,
                    address: address,
                    phone: phone,
                  );
                }
                return null;
              })
              .whereType<Mosque>()
              .toList();

          mosques.sort((a, b) => a.distance.compareTo(b.distance));
          return mosques;
        }
      } catch (e) {
        // Skip to the next URL if there is an error (timeout, socket exception, 429, etc)
        continue;
      }
    }

    throw Exception(
      'تعذر تحميل المساجد (ضغط على السيرفر). يرجى المحاولة لاحقاً',
    );
  }
}
