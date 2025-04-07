import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class StationMapPage extends StatefulWidget {
  @override
  _StationMapPageState createState() => _StationMapPageState();
}

class _StationMapPageState extends State<StationMapPage> {
  GoogleMapController? mapController;
  LatLng _pickedLocation = LatLng(20.5937, 78.9629); // Default: India coordinates

  // When map is tapped
  void _onMapTap(LatLng location) async {
    try {
      // Get the address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      String address = placemarks.isNotEmpty ? placemarks.first.street ?? 'Unknown Address' : 'Unknown Address';

      // Pass the selected location back to the form
      Navigator.pop(context, {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': address,
      });
    } catch (e) {
      // In case of any error (e.g., no internet), return default address info
      Navigator.pop(context, {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': 'Address not found',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Location')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _pickedLocation, zoom: 13),
        onMapCreated: (controller) => mapController = controller,
        onTap: _onMapTap, // Trigger when user taps on the map
      ),
    );
  }
}
