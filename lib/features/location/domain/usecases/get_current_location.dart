import 'package:geolocator/geolocator.dart';
import 'package:service_hub_ai/features/location/domain/repositories/location_repository.dart';

class GetCurrentLocation {
  final LocationRepository repository;
  GetCurrentLocation({required this.repository});

  Future<Position> call() {
    return repository.getCurrentLocation();
  }
}
