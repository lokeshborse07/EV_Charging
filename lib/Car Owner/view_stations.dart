import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'station_card.dart';
import 'book_charger_screen.dart';
import 'MapScreen.dart';

class ViewStationsScreen extends StatefulWidget {
  const ViewStationsScreen({super.key});

  @override
  _ViewStationsScreenState createState() => _ViewStationsScreenState();
}

class _ViewStationsScreenState extends State<ViewStationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _stations = [];

  @override
  void initState() {
    super.initState();
    _fetchNearbyStations();
  }

  Future<void> _fetchNearbyStations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services still disabled.');
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }

      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('stations')
          .where('verified', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> nearbyStations = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        GeoPoint? location = data['location'];

        if (location != null) {
          double distance = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            location.latitude,
            location.longitude,
          );

          if (distance <= 100000) {
            var portsSnapshot = await doc.reference.collection('ports').get();
            int availablePorts = portsSnapshot.docs.where((portDoc) {
              var portData = portDoc.data() as Map<String, dynamic>;
              bool busy = portData['busy'] ?? false;
              var bookedUntil = portData['bookedUntil']?.toDate();
              return !busy || (bookedUntil != null && DateTime.now().isAfter(bookedUntil));
            }).length;

            nearbyStations.add({
              'id': doc.id,
              'stationName': data['stationName'] ?? 'Unknown Station',
              'stationCity': data['city'] ?? 'Unknown City',
              'distance': distance / 1000,
              'rating': 4.0,
              'powerOutput': (data['powerOutput'] as num?)?.toDouble() ?? 0.0,
              'chargerType': data['chargerType'] ?? 'Unknown',
              'isBook': availablePorts > 0,
              'availablePorts': availablePorts,
              'totalPorts': (data['numChargers'] as num?)?.toInt() ?? 0,
              'imageUrl': data['imageUrl']?.toString() ?? 'https://via.placeholder.com/150',
              'geoPoint': location,
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _stations = nearbyStations;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshStations() async {
    await _fetchNearbyStations();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nearby EV Charging Stations",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen(stations: _stations)),
          );
        },
        icon: const Icon(Icons.map),
        label: const Text("View on Map"),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingFour(
              color: Colors.blue.shade900,
              size: 50.0,
            ),
            const SizedBox(height: 16),
            Text(
              "Loading Nearby Stations...",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : _stations.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ev_station, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No nearby stations found within 100 km.",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _refreshStations,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth < 600 ? 1 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: screenWidth < 600 ? 1.5 : 1.8,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final station = _stations[index];
                    return ChargingStationCard(
                      stationId: station['id'] ?? '',
                      stationName: station['stationName'] ?? 'Unknown Station',
                      location: station['stationCity'] ?? 'Unknown City',
                      distance: (station['distance'] as num?)?.toDouble() ?? 0.0,
                      rating: (station['rating'] as num?)?.toDouble() ?? 0.0,
                      powerOutput: (station['powerOutput'] as num?)?.toDouble() ?? 0.0,
                      chargerType: station['chargerType'] ?? 'Unknown',
                      isBook: station['isBook'] as bool? ?? false,
                      availablePorts: (station['availablePorts'] as num?)?.toInt() ?? 0,
                      totalPorts: (station['totalPorts'] as num?)?.toInt() ?? 0,
                      onBookNow: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookChargerScreen(
                              stationId: station['id'] ?? '',
                              stationName: station['stationName'] ?? 'Unknown Station',
                              numberOfChargers: station['totalPorts'] ?? 0,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _stations.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}