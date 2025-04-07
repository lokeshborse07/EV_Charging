import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'station_map_page.dart';

class StationForm extends StatefulWidget {
  const StationForm({super.key});

  @override
  _StationFormState createState() => _StationFormState();
}

class _StationFormState extends State<StationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _powerOutputController = TextEditingController();
  final TextEditingController _numChargersController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Fields for location
  double? _latitude;
  double? _longitude;

  // Initial values
  String _selectedCategory = 'Two Wheeler';
  String _selectedChargerType = 'AC Charger';
  bool _isLoading = false;

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationMapPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _addressController.text = result['address'] ?? '';
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _latitude != null && _longitude != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          DocumentSnapshot stationSnapshot = await _firestore.collection('stations').doc(currentUser.uid).get();

          if (stationSnapshot.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You have already added a station!')),
            );
          } else {
            // Add station to Firestore
            DocumentReference stationRef = _firestore.collection('stations').doc(currentUser.uid);
            await stationRef.set({
              'stationName': _stationNameController.text,
              'ownerName': _ownerNameController.text,
              'contactNumber': _contactNumberController.text,
              'state': _stateController.text,
              'district': _districtController.text,
              'city': _cityController.text,
              'powerOutput': double.tryParse(_powerOutputController.text) ?? 0,
              'numChargers': int.tryParse(_numChargersController.text) ?? 0,
              'category': _selectedCategory,
              'chargerType': _selectedChargerType,
              'location': GeoPoint(_latitude!, _longitude!),
              'verified': false,
            });

            // Add charger slots (ports) as a subcollection
            int numberOfChargers = int.tryParse(_numChargersController.text) ?? 0;
            for (int i = 1; i <= numberOfChargers; i++) {
              String portId = 'port$i';
              await stationRef.collection('ports').doc(portId).set({
                'portNumber': i,
                'busy': false, // Initially available
                'bookedUntil': null,
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Station and chargers added successfully!')),
            );

            // Reset the form
            _formKey.currentState?.reset();
            _latitude = null;
            _longitude = null;
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a location on the map!')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, void Function(String?) onChanged, String currentValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add EV Station"),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField('Station Name', _stationNameController),
                  _buildTextField('Owner Name', _ownerNameController),
                  _buildTextField(
                    'Contact Number',
                    _contactNumberController,
                    isNumber: true,
                    validator: (value) {
                      if (value == null || value.length != 10) {
                        return 'Enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                  _buildTextField('State', _stateController),
                  _buildTextField('District', _districtController),
                  _buildTextField('City', _cityController),
                  GestureDetector(
                    onTap: _pickLocationOnMap,
                    child: AbsorbPointer(
                      child: _buildTextField('Station Address', _addressController),
                    ),
                  ),
                  _buildTextField('Number of Chargers', _numChargersController, isNumber: true),
                  _buildTextField('Power Output (kW)', _powerOutputController, isNumber: true),
                  _buildDropdown('Category', ['Two Wheeler', 'Four Wheeler', 'Both'], (value) => setState(() => _selectedCategory = value!), _selectedCategory),
                  _buildDropdown('Charger Type', ['AC Charger', 'DC Charger'], (value) => setState(() => _selectedChargerType = value!), _selectedChargerType),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Add EV Station'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
