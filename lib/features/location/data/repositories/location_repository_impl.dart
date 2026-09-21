import 'package:geolocator/geolocator.dart';

import '../../domain/repositories/location_repository.dart';
import '../location_service.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationService locationService;

  LocationRepositoryImpl({
    required this.locationService,
  });

  @override
  Future<Position> getCurrentLocation() {
    return locationService.getCurrentLocation();
  }

  @override
  Future<String> getLocationName({
    required double latitude,
    required double longitude,
  }) {
    return locationService.getLocationName(
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Stream<Position> getLocationStream() {
    return locationService.getLocationStream();
  }
}