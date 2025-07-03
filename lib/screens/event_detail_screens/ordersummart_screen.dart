
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/event_registration_model.dart';
import '../../providers/approve_events_provider/event_registration_provider.dart';
import '../approve_event_screens/ticket_detail_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String eventImageUrl;
  final double ticketPrice;
  final String eventId;
  final String joinedBy;
  final String venueName;

  const OrderSummaryScreen({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.eventImageUrl,
    required this.ticketPrice,
    required this.eventId,
    required this.joinedBy, required this.venueName,
  }) : super(key: key);

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String? _backendUserId;
  bool _hasJoined = false;
  bool _isJoining = false;
  late Razorpay _razorpay;
  final int _ticketQuantity = 1;
  late EventRegistrationProvider provider;

  @override
  void initState() {
    super.initState();

    // Load stored user ID and joined events info
    _loadBackendUserId();

    // Initialize Razorpay instance
    _razorpay = Razorpay();

    // Set up Razorpay event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
  String getFullImageUrl(String path) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000'; // ✅ your domain
    if (path.startsWith('http')) return path;
    return '$baseUrl/${path.replaceFirst(RegExp(r'^/+'), '')}'; // ensure single slash
  }

  void _showTicketDetails() async {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final provider = EventRegistrationProvider();
    await provider.fetchRegistrations(widget.eventId);
    Navigator.pop(context); // Remove loading

    final registration = provider.registrations.firstWhere(
          (reg) => reg.id == _backendUserId,
      orElse: () => EventRegistration(
        id: '',
        name: 'Unknown',
        registrationId: '',
        eventId: '',
        status: 'Not Found',
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketDetailScreen(
          registration: registration,
          eventName: widget.eventName,
          eventDate: widget.eventDate,
          eventTime: widget.eventTime,
          eventLocation: widget.eventLocation,
          ticketPrice: widget.ticketPrice, venueName: widget.venueName,
        ),
      ),
    );
  }

  Widget _styledRow(IconData icon, String title, String value) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'approved':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'rejected':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    bool isStatus = title.toLowerCase() == 'status';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.pink.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isStatus ? getStatusColor(value) : Colors.black87,
                    fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Future<void> _loadBackendUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('backendUserId');
    final joinedEvents = prefs.getStringList('joinedEvents') ?? [];

    setState(() {
      _backendUserId = userId;
      _hasJoined = joinedEvents.contains(widget.eventId);
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Payment Successful!')),
    );
    joinEvent();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🔔 External Wallet: ${response.walletName}')),
    );
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_fQHgGz0HjzaYHN',
      'amount': ((widget.ticketPrice + 3.00) * 100).toInt(),
      'name': widget.eventName,
      'description': 'Ticket Booking',
      'prefill': {
        'contact': '9999999999',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  Future<void> joinEvent() async {
    if (_backendUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not available.')),
      );
      return;
    }

    setState(() => _isJoining = true);

    final url =
        'http://srv861272.hstgr.cloud:8000/api/event/join/${widget.eventId}';
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

      final prefs = await SharedPreferences.getInstance();
      final joinedEvents = prefs.getStringList('joinedEvents') ?? [];

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!joinedEvents.contains(widget.eventId)) {
          joinedEvents.add(widget.eventId);
          await prefs.setStringList('joinedEvents', joinedEvents);
        }

        setState(() {
          _hasJoined = true;
          _isJoining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Successfully booked')),
        );
      } else if (resBody['message']?.contains('already joined') == true) {
        if (!joinedEvents.contains(widget.eventId)) {
          joinedEvents.add(widget.eventId);
          await prefs.setStringList('joinedEvents', joinedEvents);
        }

        setState(() {
          _hasJoined = true;
          _isJoining = false;
        });
        } else {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to book: ${resBody['message']}')),
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
    final totalAmount = widget.ticketPrice + 3.00;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ticket Detail",
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
                  // Event Info
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                            Image.network(getFullImageUrl(widget.eventImageUrl),
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
                                Text(widget.eventName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('${widget.eventDate}, ${widget.eventTime}',
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(widget.eventLocation,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Order Summary",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
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
                              const Text('1 Ticket'),
                              Text('\₹${widget.ticketPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Fees'),
                              Text('\₹3.00'),
                            ],
                          ),
                          Divider(color: Colors.grey[400]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text('\₹${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Bar
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
                    _hasJoined
                        ? GestureDetector(
                      onTap: _showTicketDetails,
                      child:const Text(
                        'View Detail',
                        style: TextStyle(
                          color: Colors.green,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.green, // This line makes the underline green
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price', style: TextStyle(color: Colors.grey[700])),
                        Text(
                          '\₹${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(width: 80),
                Expanded(
                  child: GestureDetector(
                    onTap: (_hasJoined || _isJoining) ? null : _startPayment,
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
                            ? 'Booking...'
                            : (_hasJoined ? 'Booked' : 'Book'),
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
