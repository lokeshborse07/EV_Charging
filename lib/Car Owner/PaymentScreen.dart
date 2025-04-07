import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'car_owner_home.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentCancel;

  const PaymentScreen({
    super.key,
    required this.bookingData,
    required this.onPaymentSuccess,
    required this.onPaymentCancel,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  bool _paymentSuccess = false;

  // Get current user's email
  String? get _currentUserEmail => FirebaseAuth.instance.currentUser?.email;

  Future<void> _confirmPayment() async {
    if (_isProcessing) return;
    if (_currentUserEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Create booking document with car owner's email
      final bookingDataWithEmail = {
        ...widget.bookingData,
        'carOwnerEmail': _currentUserEmail, // Add email to booking data
        'createdAt': FieldValue.serverTimestamp(), // Add timestamp for sorting
        'status': 'confirmed', // Add booking status
      };

      await FirebaseFirestore.instance
          .collection('bookings')
          .add(bookingDataWithEmail);

      // 2. Update port status
      await FirebaseFirestore.instance
          .collection('stations')
          .doc(widget.bookingData['stationId'])
          .collection('ports')
          .doc('port${widget.bookingData['portNumber']}')
          .update({
        'busy': true,
        'bookedUntil': widget.bookingData['endTime'],
        'currentBookingId': bookingDataWithEmail['bookingId'], // Optional: store booking reference
      });

      // 3. Show success
      setState(() => _paymentSuccess = true);
      widget.onPaymentSuccess();

      // 4. Navigate to CarOwnerHomePage after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) =>  CarOwnerHomePage()),
                (route) => false,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  void _cancelPayment() {
    widget.onPaymentCancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.bookingData['totalPrice'] as double;
    final formattedPrice = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    ).format(totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Station', widget.bookingData['stationName']),
                    _buildDetailRow('Slot', 'Port ${widget.bookingData['portNumber']}'),
                    _buildDetailRow('Date',
                      DateFormat('MMM dd, yyyy').format(
                        (widget.bookingData['startTime'] as Timestamp).toDate(),
                      ),
                    ),
                    _buildDetailRow('Time',
                      '${DateFormat('hh:mm a').format(
                        (widget.bookingData['startTime'] as Timestamp).toDate(),
                      )} - ${DateFormat('hh:mm a').format(
                        (widget.bookingData['endTime'] as Timestamp).toDate(),
                      )}',
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Total Amount',
                      formattedPrice,
                      isBold: true,
                      textColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_paymentSuccess)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'Payment Successful!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Redirecting to homepage...'),
                  ],
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'CONFIRM PAYMENT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isProcessing ? null : _cancelPayment,
                    child: const Text(
                      'Cancel Payment',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}