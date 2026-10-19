import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // ============================================================
  // GET CURRENT GPS LOCATION
  // ============================================================

  Future<Position> getCurrentLocation() async {
    // Check if location service is enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location service is disabled.');
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();

    // Request permission if not granted
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Permission denied
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    // Permission permanently denied
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. '
        'Please enable it from settings.',
      );
    }

    // Get current GPS location
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  // ============================================================
  // GET PLACE NAME FROM LATITUDE & LONGITUDE
  // ============================================================

  Future<String> getLocationName({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Create Geocoding instance
      final geocoding = Geocoding();

      // Convert coordinates into address
      final placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return 'Location unavailable';
      }

      final place = placemarks.first;

      final parts = <String>[];

      // Example: Koratty
      if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      }

      // Example: Thrissur
      if (place.subAdministrativeArea != null &&
          place.subAdministrativeArea!.isNotEmpty &&
          !parts.contains(place.subAdministrativeArea)) {
        parts.add(place.subAdministrativeArea!);
      }

      if (parts.isEmpty) {
        return 'Location unavailable';
      }

      return parts.join(', ');
    } catch (e) {
      return 'Location unavailable';
    }
  }


  //

  Stream<Position> getLocationStream() {
  const locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  return Geolocator.getPositionStream(
    locationSettings: locationSettings,
  );
}
}
