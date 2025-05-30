import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:EVConnect/Screen/Map_page.dart';
import 'package:EVConnect/Screen/const.dart';
import 'package:EVConnect/Screen/Distance_calcutator.dart';
import 'package:EVConnect/Screen/current_lacation_store.dart';

class StationDetailsScreen extends StatefulWidget {
  final String id;
  final String stationName;
  final String stationAddress;
  final double latitude;
  final double longitude;
  final String ownerName;
  final String contactNumber;
  final String chargerType;
  final int numberOfChargers;
  final double powerOutput;
  final bool isBook;

  const StationDetailsScreen({
    super.key,
    required this.id,
    required this.stationName,
    required this.stationAddress,
    required this.latitude,
    required this.longitude,
    required this.ownerName,
    required this.contactNumber,
    required this.chargerType,
    required this.numberOfChargers,
    required this.powerOutput,
    required this.isBook,
  });

  @override
  _StationDetailsScreenState createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  double chargingCapacity = 20;
  double totalCost = 0;
  double pricePerKW = 5;

  double? latitude = LocationStorage().getLatitude();
  double? longitude = LocationStorage().getLongitude();

  @override
  Widget build(BuildContext context) {
    double dis = DistanceCalcutator.calculateDistance(
      latitude ?? Const.userLatitude,
      longitude ?? Const.userLongitude,
      widget.latitude,
      widget.longitude,
    );

    totalCost = chargingCapacity * pricePerKW;

    return Scaffold(
      appBar: AppBar(
        title: Text('Station Details'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/image/station-second-iamge.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.stationName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(widget.stationAddress, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Owner: ${widget.ownerName}'),
                    SizedBox(height: 8),
                    Text('Contact: ${widget.contactNumber}'),
                    SizedBox(height: 8),
                    Text('Charger Type: ${widget.chargerType}'),
                    SizedBox(height: 8),
                    Text('Power Output: ${widget.powerOutput}kW'),
                  ],
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MapPage(
                                dlat: widget.latitude,
                                dlong: widget.longitude,
                                slat: latitude ?? Const.userLatitude,
                                slong: longitude ?? Const.userLongitude,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 180,
                          child: Lottie.asset("assets/animation/Map-animation.json"),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("${dis.toInt()} Km away", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Set Charging Capacity (${chargingCapacity.round()}%)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: chargingCapacity,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${chargingCapacity.round()}%',
              onChanged: (value) {
                setState(() {
                  chargingCapacity = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Total Cost: ₹${totalCost.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 103, 208, 105),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (widget.isBook) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Station Is Already Booked',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.deepPurple,
                      ),
                    );
                  } else {
                    // Future payment or booking logic
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pay ₹${totalCost.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
