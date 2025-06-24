import 'package:aayo/screens/approve_event_screens/qr_ticket_screen.dart';
import 'package:flutter/material.dart';
// Import the new E-Ticket screen
import 'dart:math';

import '../home_screens/home_screen.dart'; // For generating random data for QR code

class OrderSummaryScreen extends StatefulWidget {
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String eventImageUrl;
  final double ticketPrice;

  const OrderSummaryScreen({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.eventImageUrl,
    required this.ticketPrice,
  }) : super(key: key);

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String? _selectedPaymentMethod = 'Credit/Debit Card';

  // Function to show the success dialog
  void _showSuccessDialog() {
    // Generate a random QR code data string
    final String randomQrData =
        'EventTicket_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';

    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent, // Make background transparent
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content
              children: [
                // Checkmark icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.green, // Green background for checkmark
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                // Congratulations text
                const Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Success message
                Text(
                  "You have successfully placed order for ${widget.eventName}. Enjoy the event!",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // View E-Ticket Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Dismiss dialog
                      Navigator.pushReplacement(
                        // Navigate to E-Ticket screen
                        context,
                        MaterialPageRoute(
                          builder: (context) => ETicketScreen(
                            eventName: widget.eventName,
                            eventDate: widget.eventDate,
                            eventTime: widget.eventTime,
                            eventLocation: widget.eventLocation,
                            eventImageUrl: widget.eventImageUrl,
                            ticketPrice: widget.ticketPrice,
                            qrCodeData:
                                randomQrData, // Pass the generated QR data
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFE91E63), // Pink accent color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "View E-Ticket",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Go to Home Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Dismiss dialog
                      Navigator.pushAndRemoveUntil(
                        // Go to Home and remove all previous routes
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.pinkAccent, // Text color
                      side: const BorderSide(
                          color: Colors.pinkAccent), // Border color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Go to Home",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of your existing OrderSummaryScreen build method)
    // Find the ElevatedButton for "Place Order" and update its onPressed:
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Order Detail",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Detail Card
                  Card(
                    margin: EdgeInsets.zero,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.eventImageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.eventName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.eventDate}, ${widget.eventTime}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.eventLocation,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Summary Section
                  const Text(
                    "Order Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '2x Ticket price', // Example: 2 tickets
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                              Text(
                                '\$${(widget.ticketPrice * 2).toStringAsFixed(2)}', // Calculate for 2 tickets
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                              Text(
                                '\$${(widget.ticketPrice * 2).toStringAsFixed(2)}',
                                style:  TextStyle(
                                    fontSize: 16, color:Colors.grey[700] ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fees',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                               Text(
                                '\$3.00',
                                style: TextStyle(
                                    fontSize: 16, color:Colors.grey[700] ),
                              ),
                            ],
                          ),
                           Divider(color: Colors.grey[300]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '\$${((widget.ticketPrice * 2) + 3.00).toStringAsFixed(2)}', // Total with fees
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Payment Method Section
                  const Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.asset('images/credit.png',
                              height: 30), // Replace with your card icon
                          title: const Text('Credit/Debit Card'),
                          trailing: Radio<String>(
                            value: 'Credit/Debit Card',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            },
                            activeColor: Colors.pinkAccent, // Match UI color
                          ),
                        ),
                        ListTile(
                          leading: Image.asset('images/paypal.png',
                              height: 30), // Replace with your PayPal icon
                          title: const Text('Paypal'),
                          trailing: Radio<String>(
                            value: 'Paypal',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            },
                            activeColor: Colors.pinkAccent, // Match UI color
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Persistent Bottom Bar for Price and Place Order Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '\$${((widget.ticketPrice * 2) + 3.00).toStringAsFixed(2)}', // Total price here
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 80,),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _showSuccessDialog, // Call the new dialog function
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFE91E63), // Pink accent color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical:16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
