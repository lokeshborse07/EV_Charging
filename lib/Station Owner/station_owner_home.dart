import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_page.dart';
import 'add_station.dart';
import 'view_bookings.dart';
import 'package:ev_charging/shared_preferences/shared_preferences_helper.dart';
import 'ProfilePage.dart';  // Import the ProfilePage
import 'viewstation.dart';

class StationOwnerHomePage extends StatefulWidget {
  @override
  _StationOwnerHomePageState createState() => _StationOwnerHomePageState();
}

class _StationOwnerHomePageState extends State<StationOwnerHomePage> {
  String ownerName = "John Doe";
  String ownerMobile = "+1234567890";
  String ownerEmail = "john.doe@example.com";
  String selectedTheme = "Light";  // Default theme
  String selectedLanguage = "English";  // Default language

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  ValueNotifier<ThemeData> themeNotifier = ValueNotifier(ThemeData.light());

  // Load settings on login
  _loadSettings() async {
    String? savedTheme = await SharedPreferencesHelper.getTheme();
    String? savedLanguage = await SharedPreferencesHelper.getLanguage();

    setState(() {
      selectedTheme = savedTheme!;
      selectedLanguage = savedLanguage!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define themeData inside the build method
    ThemeData themeData = selectedTheme == 'Dark' ? ThemeData.dark() : ThemeData.light();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Station Owner Dashboard", style: GoogleFonts.poppins()),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pop(context); // Logout
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
                icon: Icons.electric_car,
                label: 'ADD STATIONS',
                color: Colors.green,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StationForm()));
                },
              ),
              DashboardItem(
                icon: Icons.calendar_today,
                label: 'VIEW BOOKINGS',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StationOwnerBookingsPage()));
                },
              ),
              DashboardItem(
                icon: Icons.location_on,  // New icon for view/edit stations
                label: 'MY STATIONS',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewStationsPage()));
                },
              ),
              DashboardItem(
                icon: Icons.person,
                label: 'PROFILE',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())); // Corrected navigation
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