import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the pages
import 'add_station.dart'; // Import the Add Station Page
import 'view_bookings.dart'; // Import the View Bookings Page

class StationOwnerHomePage extends StatefulWidget {
  @override
  _StationOwnerHomePageState createState() => _StationOwnerHomePageState();
}

class _StationOwnerHomePageState extends State<StationOwnerHomePage> {
  // Placeholder for station owner data, replace with actual data fetched from the database
  String ownerName = "John Doe";
  String ownerMobile = "+1234567890";
  String ownerEmail = "john.doe@example.com";

  // Logout functionality
  void _logout() {
    print("Logging out...");
    // Implement actual logout functionality (e.g., Firebase auth sign-out)
    Navigator.pop(context); // Close the current screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Station Owner Dashboard", style: GoogleFonts.poppins()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Logout when clicked
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            // Add Station Button
            DashboardItem(
              icon: Icons.electric_car,
              label: 'ADD STATIONS',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddStationPage()),
                );
              },
            ),
            // View Bookings Button
            DashboardItem(
              icon: Icons.calendar_today,
              label: 'VIEW BOOKINGS',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewBookingsPage()),
                );
              },
            ),
            // Profile Button
            DashboardItem(
              icon: Icons.person,
              label: 'PROFILE',
              onTap: () {
                // Navigate to Profile Page (add your profile page logic here)
                print("Navigating to Profile");
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  DashboardItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.black54),
            SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
