import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CarDetailsScreen extends StatefulWidget {
  final String stationId;
  final int selectedCharger; // Changed to int
  final int selectedPower;
  final double calculatedPrice;

  const CarDetailsScreen({
    super.key, // Explicitly include the Key
    required this.stationId,
    required this.selectedCharger,
    required this.selectedPower,
    required this.calculatedPrice,
  });

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
    // TODO: Store booking details in Firestore
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Used: ${response.walletName}")),
    );
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _payNow() {
    var options = {
      "key": "rzp_test_ABC123XYZ", // Replace with your Razorpay test key
      "amount": (widget.calculatedPrice * 100).toInt(), // Convert to paise
      "name": "EV Charging Payment",
      "description": "Charging at Charger ${widget.selectedCharger}",
      "prefill": {
        "contact": _mobileController.text,
      },
    };
    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Car Details & Booking")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Car Owner Name"),
                validator: (value) => value!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Mobile Number"),
                validator: (value) =>
                value!.length != 10 ? "Enter a valid 10-digit number" : null,
              ),
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(labelText: "Vehicle Number"),
                validator: (value) => value!.isEmpty ? "Enter vehicle number" : null,
              ),
              TextFormField(
                controller: _vehicleModelController,
                decoration: const InputDecoration(labelText: "Vehicle Model"),
                validator: (value) => value!.isEmpty ? "Enter vehicle model" : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(_selectedDate == null
                    ? "Select Date"
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              if (_selectedDate == null)
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Please select a date",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Select Time Slot"),
                items: ["09:00 - 11:00 AM", "11:00 - 01:00 PM", "03:00 - 05:00 PM"]
                    .map((slot) {
                  return DropdownMenuItem(value: slot, child: Text(slot));
                }).toList(),
                onChanged: (value) => setState(() => _selectedTimeSlot = value),
                validator: (value) => value == null ? "Select a time slot" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null &&
                      _selectedTimeSlot != null) {
                    _payNow();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all details")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text("Confirm & Pay ₹${widget.calculatedPrice.toStringAsFixed(2)}"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
