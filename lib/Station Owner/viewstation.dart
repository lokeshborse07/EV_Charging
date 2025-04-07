import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewStationsPage extends StatefulWidget {
  @override
  _ViewStationsPageState createState() => _ViewStationsPageState();
}

class _ViewStationsPageState extends State<ViewStationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String? _stationId;
  DocumentSnapshot? _stationDoc;
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers for all fields
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _chargerTypeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _powerOutputController = TextEditingController();
  final TextEditingController _numChargersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStationData();
  }

  Future<void> _fetchStationData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final stationDoc = await _firestore.collection('stations').doc(user.uid).get();
        if (stationDoc.exists) {
          setState(() {
            _stationId = user.uid;
            _stationDoc = stationDoc;
            // Initialize all controllers with data from Firestore
            _stationNameController.text = stationDoc['stationName'] ?? '';
            _ownerNameController.text = stationDoc['ownerName'] ?? '';
            _contactNumberController.text = stationDoc['contactNumber'] ?? '';
            _categoryController.text = stationDoc['category'] ?? '';
            _chargerTypeController.text = stationDoc['chargerType'] ?? '';
            _cityController.text = stationDoc['city'] ?? '';
            _districtController.text = stationDoc['district'] ?? '';
            _stateController.text = stationDoc['state'] ?? '';
            _powerOutputController.text = stationDoc['powerOutput']?.toString() ?? '';
            _numChargersController.text = stationDoc['numChargers']?.toString() ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No station found for this user')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching station data: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateStationData() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        await _firestore.collection('stations').doc(_stationId).update({
          'stationName': _stationNameController.text,
          'ownerName': _ownerNameController.text,
          'contactNumber': _contactNumberController.text,
          'category': _categoryController.text,
          'chargerType': _chargerTypeController.text,
          'city': _cityController.text,
          'district': _districtController.text,
          'state': _stateController.text,
          'powerOutput': int.tryParse(_powerOutputController.text) ?? 0,
          'numChargers': int.tryParse(_numChargersController.text) ?? 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Refresh the data after update
        await _fetchStationData();

        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Station updated successfully')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating station: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildViewMode() {
    final geoPoint = _stationDoc?['location'] as GeoPoint?;
    final locationText = geoPoint != null
        ? '${geoPoint.latitude.toStringAsFixed(6)}° N, ${geoPoint.longitude.toStringAsFixed(6)}° E'
        : 'Not set';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Station Header Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.only(bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade800, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.ev_station, size: 30, color: Colors.white),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            _stationDoc?['stationName'] ?? 'My Station',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${_stationDoc?['city'] ?? ''}, ${_stationDoc?['state'] ?? ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Station Details Section
          Text('STATION DETAILS', style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          )),
          SizedBox(height: 10),

          // Details Grid - Fixed the overflow issues here
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3.2, // Increased slightly to accommodate content
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildDetailCard(Icons.person, 'Owner', _stationDoc?['ownerName'] ?? 'N/A'),
              _buildDetailCard(Icons.phone, 'Contact', _stationDoc?['contactNumber'] ?? 'N/A'),
              _buildDetailCard(Icons.category, 'Category', _stationDoc?['category'] ?? 'N/A'),
              _buildDetailCard(Icons.bolt, 'Charger Type', _stationDoc?['chargerType'] ?? 'N/A'),
              _buildDetailCard(Icons.location_city, 'City', _stationDoc?['city'] ?? 'N/A'),
              _buildDetailCard(Icons.map, 'District', _stationDoc?['district'] ?? 'N/A'),
              _buildDetailCard(Icons.flag, 'State', _stationDoc?['state'] ?? 'N/A'),
              _buildDetailCard(Icons.power, 'Power Output', '${_stationDoc?['powerOutput'] ?? 0} kW'),
              _buildDetailCard(Icons.electrical_services, 'Chargers', _stationDoc?['numChargers']?.toString() ?? '0'),
              _buildDetailCard(Icons.verified, 'Verified', _stationDoc?['verified'] == true ? 'Yes' : 'No'),
            ],
          ),

          // Location Card
          SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_pin, color: Colors.red),
                      SizedBox(width: 8),
                      Text('LOCATION', style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      )),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(locationText, style: GoogleFonts.poppins()),
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Icon(Icons.map, size: 50, color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Edit Button
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text('EDIT STATION DETAILS', style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero, // Remove any default margins
      child: Container(
        constraints: BoxConstraints(
          minHeight: 60, // Set a minimum height that works for your content
        ),
        padding: EdgeInsets.all(8), // Reduced padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.blue.shade800), // Smaller icon
            SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 10, // Smaller font size
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 12, // Smaller font size
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _isEditing = false),
                ),
                SizedBox(width: 10),
                Text('Edit Station', style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
            SizedBox(height: 20),

            // Edit Form
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildEditFieldWithIcon(
                      _stationNameController,
                      'Station Name',
                      'Enter station name',
                      Icons.ev_station,
                    ),
                    SizedBox(height: 15),
                    _buildEditFieldWithIcon(
                      _ownerNameController,
                      'Owner Name',
                      'Enter owner name',
                      Icons.person,
                    ),
                    SizedBox(height: 15),
                    _buildEditFieldWithIcon(
                      _contactNumberController,
                      'Contact Number',
                      'Enter contact number',
                      Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    _buildEditFieldWithIcon(
                      _categoryController,
                      'Category',
                      'Enter category',
                      Icons.category,
                    ),
                    SizedBox(height: 15),
                    _buildEditFieldWithIcon(
                      _chargerTypeController,
                      'Charger Type',
                      'Enter charger type',
                      Icons.bolt,
                    ),
                    SizedBox(height: 15),
                    _buildEditFieldWithIcon(
                      _cityController,
                      'City',
                      'Enter city',
                      Icons.location_city,
                    ),
                    SizedBox(height: 15),
                    _buildEditFieldWithIcon(
                      _districtController,
                      'District',
                      'Enter district',
                      Icons.map,
                    ),
                    SizedBox(height: 15),
                    _buildEditFieldWithIcon(
                      _stateController,
                      'State',
                      'Enter state',
                      Icons.flag,
                    ),
                    SizedBox(height: 15),
                    _buildEditFieldWithIcon(
                      _powerOutputController,
                      'Power Output (kW)',
                      'Enter power output',
                      Icons.power,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    _buildEditFieldWithIcon(
                      _numChargersController,
                      'Number of Chargers',
                      'Enter number of chargers',
                      Icons.electrical_services,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateStationData,
                child: _isLoading
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : Text('SAVE CHANGES', style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditFieldWithIcon(
      TextEditingController controller,
      String label,
      String hint,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Station', style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _stationDoc == null
          ? Center(child: Text('No station data found', style: GoogleFonts.poppins()))
          : _isEditing ? _buildEditMode() : _buildViewMode(),
    );
  }

  @override
  void dispose() {
    _stationNameController.dispose();
    _ownerNameController.dispose();
    _contactNumberController.dispose();
    _categoryController.dispose();
    _chargerTypeController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _powerOutputController.dispose();
    _numChargersController.dispose();
    super.dispose();
  }
}