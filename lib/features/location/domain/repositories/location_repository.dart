import 'package:geolocator/geolocator.dart';

abstract class LocationRepository {
  Future<Position> getCurrentLocation();

  Future<String> getLocationName({
    required double latitude,
    required double longitude,
  });

  Stream<Position> getLocationStream();
}