import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewBookingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Bookings", style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: 5, // For demo purposes, you can replace this with actual data from your database
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text("Booking #$index", style: GoogleFonts.poppins(fontSize: 16)),
                subtitle: Text("Car Owner: John Doe\nTime: 10:00 AM\nStatus: Confirmed", style: GoogleFonts.poppins(fontSize: 14)),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // You can navigate to a booking detail page here
                  print("Viewing booking details for booking #$index");
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
