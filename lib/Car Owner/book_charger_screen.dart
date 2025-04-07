import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'booking_form_screen.dart';

class BookChargerScreen extends StatefulWidget {
  final String stationId;
  final String stationName;
  final int numberOfChargers;

  const BookChargerScreen({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.numberOfChargers,
  });

  @override
  State<BookChargerScreen> createState() => _BookChargerScreenState();
}

class _BookChargerScreenState extends State<BookChargerScreen> {
  int? selectedSlot;
  double selectedPower = 10.0;
  final double pricePerPercent = 20.0;
  final Map<int, bool> slotAvailability = {};

  @override
  void initState() {
    super.initState();
    _initializeSlotAvailability();
    _setupSlotListener();
  }

  Future<void> _initializeSlotAvailability() async {
    for (int i = 1; i <= widget.numberOfChargers; i++) {
      final isAvailable = await _checkSlotAvailability(i);
      if (mounted) {
        setState(() {
          slotAvailability[i] = isAvailable;
        });
      }
    }
  }

  void _setupSlotListener() {
    FirebaseFirestore.instance
        .collection('stations')
        .doc(widget.stationId)
        .collection('ports')
        .snapshots()
        .listen((snapshot) {
      _updateSlotAvailability();
    });
  }

  Future<bool> _checkSlotAvailability(int slotNumber) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('stations')
          .doc(widget.stationId)
          .collection('ports')
          .doc('port$slotNumber')
          .get();

      if (!doc.exists) return true;

      final data = doc.data()!;
      final bool isBusy = data['busy'] ?? false;
      final Timestamp? bookedUntil = data['bookedUntil'];

      return !isBusy ||
          (bookedUntil != null && DateTime.now().isAfter(bookedUntil.toDate()));
    } catch (e) {
      debugPrint('Error checking slot availability: $e');
      return false;
    }
  }

  Future<void> _updateSlotAvailability() async {
    for (int i = 1; i <= widget.numberOfChargers; i++) {
      final isAvailable = await _checkSlotAvailability(i);
      if (mounted) {
        setState(() {
          slotAvailability[i] = isAvailable;
        });
      }
    }
  }

  void _handleBookingConfirmation() {
    if (selectedSlot == null) {
      Fluttertoast.showToast(
        msg: "Please select a slot first",
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!(slotAvailability[selectedSlot!] ?? false)) {
      Fluttertoast.showToast(
        msg: "This slot is no longer available",
        backgroundColor: Colors.red,
      );
      return;
    }

    final totalPrice = selectedPower * pricePerPercent;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(
          stationId: widget.stationId,
          stationName: widget.stationName,
          selectedSlot: selectedSlot!,
          totalPrice: totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book at ${widget.stationName}'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Charger Slot:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(widget.numberOfChargers, (index) {
                final slotNumber = index + 1;
                final isAvailable = slotAvailability[slotNumber] ?? false;

                return GestureDetector(
                  onTap: isAvailable ? () {
                    setState(() {
                      selectedSlot = slotNumber;
                    });
                  } : null,
                  child: Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: selectedSlot == slotNumber
                          ? Colors.blue.shade900
                          : isAvailable
                          ? Colors.grey.shade200
                          : Colors.red.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedSlot == slotNumber
                            ? Colors.blue.shade700
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Charger $slotNumber',
                        style: TextStyle(
                          color: selectedSlot == slotNumber
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Power Percentage:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: selectedPower,
              min: 10,
              max: 100,
              divisions: 9,
              label: '${selectedPower.round()}%',
              onChanged: (value) => setState(() => selectedPower = value),
            ),
            const SizedBox(height: 16),
            Text(
              'Estimated Price: ₹${(selectedPower * pricePerPercent).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleBookingConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue to Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}