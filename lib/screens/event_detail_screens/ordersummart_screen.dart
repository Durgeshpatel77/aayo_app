import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../home_screens/home_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String eventImageUrl;
  final double ticketPrice;
  final String eventId;
  final String joinedBy; // This 'joinedBy' is for passing initial data, not the one for API call

  const OrderSummaryScreen({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.eventImageUrl,
    required this.ticketPrice,
    required this.eventId,
    required this.joinedBy,
  }) : super(key: key);

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String? _selectedPaymentMethod = 'Credit/Debit Card';
  String? _backendUserId; // To store the backend user ID from SharedPreferences
  bool _hasJoined = false;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _loadBackendUserId();
  }

  // Function to load the backend user ID from SharedPreferences
  Future<void> _loadBackendUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _backendUserId = prefs.getString('backendUserId');
    });
  }

  Future<void> joinEvent() async {
    if (_backendUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not available.')),
      );
      return;
    }

    setState(() => _isJoining = true);

    final url = 'http://srv861272.hstgr.cloud:8000/api/event/join/${widget.eventId}';
    final headers = {'Content-Type': 'application/json'};
    final body = {'joinedBy': _backendUserId!};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      final resBody = json.decode(response.body);
      debugPrint('📥 Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _hasJoined = true;
          _isJoining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Successfully joined')),
        );
      } else if (resBody['message']?.contains('already joined') == true) {
        setState(() {
          _hasJoined = true;
          _isJoining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ You already joined this event')),
        );
      } else {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to join: ${resBody['message']}')),
        );
      }
    } catch (e) {
      setState(() => _isJoining = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  const Text(
                    "Order Summary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('2x Ticket price',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700])),
                              Text(
                                  '\$${(widget.ticketPrice * 2).toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700])),
                              Text(
                                  '\$${(widget.ticketPrice * 2).toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Fees',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700])),
                              const Text('\$3.00',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
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
                                ),
                              ),
                              Text(
                                '\$${((widget.ticketPrice * 2) + 3.00).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Payment Method",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading:
                          Image.asset('images/credit.png', height: 30),
                          title: const Text('Credit/Debit Card'),
                          trailing: Radio<String>(
                            value: 'Credit/Debit Card',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            },
                            activeColor: Colors.pinkAccent,
                          ),
                        ),
                        ListTile(
                          leading: Image.asset('images/paypal.png', height: 30),
                          title: const Text('Paypal'),
                          trailing: Radio<String>(
                            value: 'Paypal',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            },
                            activeColor: Colors.pinkAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                  children: [
                    Text('Price', style: TextStyle(color: Colors.grey[700])),
                    Text(
                      '\$${((widget.ticketPrice * 2) + 3.00).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 80),
                Expanded(
                  child:
                  GestureDetector(
                    onTap: (_hasJoined || _isJoining) ? null : joinEvent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _hasJoined
                            ? Colors.grey.shade600
                            : _isJoining
                            ? Colors.pink.shade300
                            : const Color(0xFFE91E63),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (!_hasJoined && !_isJoining)
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 6,
                            ),
                        ],
                      ),
                      child: Text(
                        _isJoining
                            ? 'Joining...'
                            : (_hasJoined ? 'Joined' : 'Join'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
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