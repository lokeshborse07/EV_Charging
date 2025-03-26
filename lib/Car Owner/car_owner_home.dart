import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CarOwnerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Car Owner Home", style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, Car Owner!",
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.ev_station, color: Colors.blue),
                title: Text("Find Nearby Charging Stations", style: GoogleFonts.poppins()),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.green),
                title: Text("View Booking History", style: GoogleFonts.poppins()),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(Icons.settings, color: Colors.orange),
                title: Text("Account Settings", style: GoogleFonts.poppins()),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}