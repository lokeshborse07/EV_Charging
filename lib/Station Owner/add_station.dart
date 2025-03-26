import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStationPage extends StatefulWidget {
  @override
  _AddStationPageState createState() => _AddStationPageState();
}

class _AddStationPageState extends State<AddStationPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController stationNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController chargingPointsController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Here, you would save the station data or send it to the server.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Station Added Successfully!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Station", style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: stationNameController,
                decoration: InputDecoration(labelText: "Station Name"),
                validator: (value) => value!.isEmpty ? "Enter station name" : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: "Location"),
                validator: (value) => value!.isEmpty ? "Enter location" : null,
              ),
              TextFormField(
                controller: chargingPointsController,
                decoration: InputDecoration(labelText: "Number of Charging Points"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter number of charging points" : null,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text("Add Station", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
