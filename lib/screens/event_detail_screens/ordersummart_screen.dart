import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    required this.joinedBy,
    required this.venueName,
  }) : super(key: key);

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String? _backendUserId;
  bool _hasJoined = false;
  bool _isJoining = false;
  late Razorpay _razorpay;
  bool _hasCancelled = false;  // ➕ Add this


  @override
  void initState() {
    super.initState();
    _loadBackendUserId();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
  Future<bool> _showCancelBookingDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Cancel Booking?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Are you sure you want to cancel your ticket for this free event?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('No'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('Yes',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ?? false;
  }

  String getFullImageUrl(String path) {
    const baseUrl = 'http://82.29.167.118:8000';
    if (path.startsWith('http')) return path;
    return '$baseUrl/${path.replaceFirst(RegExp(r'^/+'), '')}';
  }

  Future<void> _loadBackendUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('backendUserId');
    final joinedEvents = prefs.getStringList('joinedEvents') ?? [];
    final cancelledEvents = prefs.getStringList('cancelledEvents') ?? []; // ➕ new

    setState(() {
      _backendUserId = userId;
      _hasJoined = joinedEvents.contains(widget.eventId);
      _hasCancelled = cancelledEvents.contains(widget.eventId);  // ➕ track cancel
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
    if (widget.ticketPrice == 0.0) {
      joinEvent();
      return;
    }

    var options = {
      'key': 'rzp_test_fQHgGz0HjzaYHN',
      'amount': (widget.ticketPrice * 100).toInt(),
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

    final url = 'http://82.29.167.118:8000/api/event/join/${widget.eventId}';
    final headers = {'Content-Type': 'application/json'};
    final body = {'joinedBy': _backendUserId!};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      final resBody = json.decode(response.body);
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

  Future<void> _cancelBooking() async {
    debugPrint('🔶 Starting cancelBooking');
    debugPrint('🔶 Event ID: ${widget.eventId}');
    debugPrint('🔶 Backend User ID: $_backendUserId');

    final confirm = await _showCancelBookingDialog();
    if (confirm != true) {
      debugPrint('🔶 User cancelled the dialog');
      return;
    }

    if (_backendUserId == null) {
      debugPrint('❌ Backend user ID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found.')),
      );
      return;
    }

    // ✅ Fetch registrations for this event
    final provider = EventRegistrationProvider();
    await provider.fetchRegistrations(widget.eventId);
    debugPrint('✅ Registrations fetched: ${provider.registrations.length}');

    // 🔍 Debug print each registration to inspect values
    for (var reg in provider.registrations) {
      debugPrint('🔍 Registration => id=${reg.id}, registrationId=${reg.registrationId}, eventId=${reg.eventId}, status=${reg.status}');
    }

    if (provider.registrations.isEmpty) {
      debugPrint('❌ No registrations found for this event');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No registration found to cancel.')),
      );
      return;
    }

    final matchingReg = provider.registrations.first;
    debugPrint('✅ Found registrationId (eventRegId): ${matchingReg.registrationId}');

    final eventRegId = matchingReg.registrationId;

    final url = 'http://82.29.167.118:8000/api/event/update-status/${widget.eventId}';
    final headers = {'Content-Type': 'application/json'};
    final body = {
      "joinedBy": _backendUserId!,
      "eventRegId": eventRegId,
      "status": "cancelled",
    };

    debugPrint('📤 Sending cancel request to: $url');
    debugPrint('📤 Request Body: $body');

    try {
      final cancelResponse = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      debugPrint('📥 Cancel Status Code: ${cancelResponse.statusCode}');
      debugPrint('📥 Cancel Response Body: ${cancelResponse.body}');

      if (cancelResponse.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        // Remove from joinedEvents
        final joinedEvents = prefs.getStringList('joinedEvents') ?? [];
        joinedEvents.remove(widget.eventId);
        await prefs.setStringList('joinedEvents', joinedEvents);

        // 🔥 Save to cancelledEvents
        List<String> cancelledEvents = prefs.getStringList('cancelledEvents') ?? [];
        if (!cancelledEvents.contains(widget.eventId)) {
          cancelledEvents.add(widget.eventId);
          await prefs.setStringList('cancelledEvents', cancelledEvents);
        }

        setState(() {
          _hasJoined = false;
          _hasCancelled = true; // ➕ Booking disabled flag
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Booking Cancelled')),
        );
      } else {
        final resBody = json.decode(cancelResponse.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: ${resBody['message']}')),
        );
      }
    } catch (e) {
      debugPrint('❌ Exception during cancellation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showTicketDetails() async {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final provider = EventRegistrationProvider();
    await provider.fetchRegistrations(widget.eventId);
    Navigator.pop(context);

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
          ticketPrice: widget.ticketPrice,
          venueName: widget.venueName,
        ),
      ),
    );
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
                            child: Image.network(
                              getFullImageUrl(widget.eventImageUrl),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                              Text(widget.ticketPrice == 0.0
                                  ? 'Free'
                                  : '\₹${widget.ticketPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.grey[400]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(
                                widget.ticketPrice == 0.0
                                    ? 'Free'
                                    : '\₹${widget.ticketPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _hasJoined
                    ? GestureDetector(
                  onTap: _showTicketDetails,
                  child: const Text(
                    'View Detail',
                    style: TextStyle(
                      color: Colors.green,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price', style: TextStyle(color: Colors.grey[700])),
                    Text(widget.ticketPrice == 0.0
                        ? 'Free'
                        : '\₹${widget.ticketPrice.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(width: 80),
                Expanded(
                  child: GestureDetector(
                    onTap: _isJoining
                        ? null
                        : _hasCancelled
                        ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You already canceled joining this event.')),
                      );
                    }
                        : _hasJoined
                        ? (widget.ticketPrice == 0.0 ? _cancelBooking : null)
                        : _startPayment,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _isJoining
                            ? Colors.pink.shade300
                            : (_hasCancelled
                            ? Colors.grey // Disabled color
                            : _hasJoined
                            ? (widget.ticketPrice == 0.0 ? Colors.redAccent : Colors.grey.shade600)
                            : const Color(0xFFE91E63)),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (!_hasJoined && !_isJoining && !_hasCancelled)
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
                            : (_hasCancelled
                            ? 'Booking Disabled'
                            : (_hasJoined
                            ? (widget.ticketPrice == 0.0 ? 'Cancel Booking' : 'Booked')
                            : 'Book')),
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
