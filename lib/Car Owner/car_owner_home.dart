import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_stations.dart';
import 'view_bookings.dart'; // Make sure to create this file
import 'profile_page.dart'; // Make sure to create this file
import 'settings_page.dart';

class CarOwnerHomePage extends StatefulWidget {
  @override
  _CarOwnerHomePageState createState() => _CarOwnerHomePageState();
}

class _CarOwnerHomePageState extends State<CarOwnerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Car Owner Dashboard", style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context); // Logout action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            DashboardItem(
              icon: Icons.ev_station,
              label: 'VIEW STATIONS',
              color: Colors.green,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewStationsScreen()));
              },
            ),
            DashboardItem(
              icon: Icons.calendar_today,
              label: 'VIEW BOOKINGS',
              color: Colors.blue,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CarOwnerBookingsPage()));
              },
            ),
            DashboardItem(
              icon: Icons.person,
              label: 'PROFILE',
              color: Colors.orange,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CarOwnerProfilePage()));
              },
            ),
            DashboardItem(
              icon: Icons.settings,
              label: 'SETTINGS',
              color: Colors.purple,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
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
  final Color color;

  DashboardItem({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.6), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}