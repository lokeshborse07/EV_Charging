import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'PaymentScreen.dart';

class BookingFormScreen extends StatefulWidget {
  final String stationId;
  final String stationName;
  final int selectedSlot;
  final double totalPrice;

  const BookingFormScreen({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.selectedSlot,
    required this.totalPrice,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehiclePlateNumberController = TextEditingController();
  final _mobileNumberController = TextEditingController();

  String _vehicleType = 'Two Wheeler';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isProcessing = false;

  Future<bool> _isSlotAvailable() async {
    try {
      final slotDoc = await FirebaseFirestore.instance
          .collection('stations')
          .doc(widget.stationId)
          .collection('ports')
          .doc('port${widget.selectedSlot}')
          .get();

      if (!slotDoc.exists) return true;

      final data = slotDoc.data() as Map<String, dynamic>;
      final bool isBusy = data['busy'] ?? false;
      final Timestamp? bookedUntil = data['bookedUntil'];

      return !isBusy || (bookedUntil != null && DateTime.now().isAfter(bookedUntil.toDate()));
    } catch (e) {
      debugPrint('Error checking slot availability: $e');
      return false;
    }
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fill all required fields");
      return;
    }

    if (_startTime == null || _endTime == null) {
      Fluttertoast.showToast(msg: "Please select both start and end times");
      return;
    }

    if (!_isEndTimeValid(_endTime!)) {
      Fluttertoast.showToast(msg: "End time must be after start time");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final isAvailable = await _isSlotAvailable();
      if (!isAvailable) {
        Fluttertoast.showToast(msg: "This slot is no longer available");
        return;
      }

      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Reserve the slot temporarily
      await FirebaseFirestore.instance
          .collection('stations')
          .doc(widget.stationId)
          .collection('ports')
          .doc('port${widget.selectedSlot}')
          .update({
        'busy': true,
        'bookedUntil': Timestamp.fromDate(endDateTime),
      });

      final bookingData = {
        'stationId': widget.stationId,
        'stationName': widget.stationName,
        'portNumber': widget.selectedSlot,
        'customerName': _nameController.text,
        'vehicleType': _vehicleType,
        'vehicleModel': _vehicleModelController.text,
        'vehicleNumber': _vehiclePlateNumberController.text,
        'mobileNumber': _mobileNumberController.text,
        'startTime': Timestamp.fromDate(startDateTime),
        'endTime': Timestamp.fromDate(endDateTime),
        'totalPrice': widget.totalPrice,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      };

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              bookingData: bookingData,
              onPaymentSuccess: () {
                // Handle success in payment screen
              },
              onPaymentCancel: () async {
                // Release the slot if payment is cancelled
                await FirebaseFirestore.instance
                    .collection('stations')
                    .doc(widget.stationId)
                    .collection('ports')
                    .doc('port${widget.selectedSlot}')
                    .update({
                  'busy': false,
                  'bookedUntil': null,
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error processing booking: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  bool _isEndTimeValid(TimeOfDay endTime) {
    if (_startTime == null) return false;
    return endTime.hour > _startTime!.hour ||
        (endTime.hour == _startTime!.hour && endTime.minute > _startTime!.minute);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vehicleModelController.dispose();
    _vehiclePlateNumberController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking - ${widget.stationName}"),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                label: 'Full Name',
                controller: _nameController,
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              _buildVehicleTypeDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Vehicle Model',
                controller: _vehicleModelController,
                validator: (value) => value!.isEmpty ? 'Please enter vehicle model' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'License Plate Number',
                controller: _vehiclePlateNumberController,
                validator: (value) => value!.isEmpty ? 'Please enter plate number' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Mobile Number',
                controller: _mobileNumberController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter mobile number';
                  if (value.length < 10) return 'Enter valid mobile number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildDateSelector(),
              const SizedBox(height: 16),
              _buildTimeSelector(),
              const SizedBox(height: 32),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Vehicle Type',
        border: OutlineInputBorder(),
      ),
      value: _vehicleType,
      items: const [
        DropdownMenuItem(value: 'Two Wheeler', child: Text('Two Wheeler')),
        DropdownMenuItem(value: 'Four Wheeler', child: Text('Four Wheeler')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _vehicleType = value);
        }
      },
      validator: (value) => value == null ? 'Please select vehicle type' : null,
    );
  }

  Widget _buildDateSelector() {
    return ListTile(
      title: Text(
        "Booking Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}",
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate != null && mounted) {
          setState(() => _selectedDate = pickedDate);
        }
      },
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      children: [
        ListTile(
          title: Text(
            "Start Time: ${_startTime?.format(context) ?? 'Not selected'}",
            style: const TextStyle(fontSize: 16),
          ),
          trailing: const Icon(Icons.access_time),
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: _startTime ?? TimeOfDay.now(),
            );
            if (pickedTime != null && mounted) {
              setState(() {
                _startTime = pickedTime;
                _endTime = null;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        ListTile(
          title: Text(
            "End Time: ${_endTime?.format(context) ?? 'Not selected'}",
            style: const TextStyle(fontSize: 16),
          ),
          trailing: const Icon(Icons.access_time),
          onTap: _startTime == null
              ? null
              : () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: _startTime!.replacing(hour: _startTime!.hour + 1),
            );
            if (pickedTime != null && _isEndTimeValid(pickedTime) && mounted) {
              setState(() => _endTime = pickedTime);
            } else if (pickedTime != null) {
              Fluttertoast.showToast(msg: "End time must be after start time");
            }
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _proceedToPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "CONFIRM & PAY",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}