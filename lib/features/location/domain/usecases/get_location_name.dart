import '../repositories/location_repository.dart';

class GetLocationName {
  final LocationRepository repository;

  GetLocationName({
    required this.repository,
  });

  Future<String> call({
    required double latitude,
    required double longitude,
  }) {
    return repository.getLocationName(
      latitude: latitude,
      longitude: longitude,
    );
  }
}