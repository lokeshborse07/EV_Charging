import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Checks if location services are enabled
  static Future<bool> _checkLocationService() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks and requests location permissions
  static Future<LocationPermission> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Gets the current position with error handling
  static Future<Position> getCurrentPosition({
    LocationAccuracy locationAccuracy = LocationAccuracy.high,
  }) async {
    try {
      // Step 1: Check if location services are enabled
      final serviceEnabled = await _checkLocationService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable them.');
      }

      // Step 2: Check and request permissions
      final permission = await _checkPermissions();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied');
      }

      // Step 3: Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: locationAccuracy,
      );
    } catch (e) {
      print('LocationService Error: $e');
      rethrow;
    }
  }

  /// Calculates distance between two coordinates in kilometers
  static double calculateDistanceInKm(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert meters to kilometers
  }

  /// Gets the last known position (cached)
  static Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  /// Listens to location updates (for real-time tracking)
  static Stream<Position> getPositionStream({
    LocationAccuracy locationAccuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    final locationSettings = LocationSettings(
      accuracy: locationAccuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }
}