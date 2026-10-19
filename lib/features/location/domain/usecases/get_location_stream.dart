import 'package:geolocator/geolocator.dart';

import '../repositories/location_repository.dart';

class GetLocationStream {
  final LocationRepository repository;

  GetLocationStream({
    required this.repository,
  });

  Stream<Position> call() {
    return repository.getLocationStream();
  }
}