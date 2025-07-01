// lib/screens/approve_event_screens/ticket_detail_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/event_registration_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final EventRegistration registration;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final double ticketPrice;
  final String venueName;

  const TicketDetailScreen({
    Key? key,
    required this.registration,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.eventLocation,
    required this.ticketPrice,
    required this.venueName, // ✅ new

  }) : super(key: key);

  String capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _generateInvoiceNo(String id) {
    if (id.isEmpty || id.length < 6) return 'INV-XXXXXX';
    return 'INV-${id.substring(0, 6).toUpperCase()}';
  }

  String _generateSerialNo() {
    return 'SN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 12)}';
  }

  String _generateTicketNo() {
    return 'TKT-${Random().nextInt(999999).toString().padLeft(6, '0')}';
  }

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

  @override
  Widget build(BuildContext context) {
    final invoiceNo = _generateInvoiceNo(registration.id);
    final serialNo = _generateSerialNo();
    final ticketNo = _generateTicketNo();
    final total = ticketPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Ticket Invoice',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 30),

              _sectionTitle('Event Details'),
              _infoRow('Event Name', capitalize(eventName)),
              _infoRow('Venue', capitalize(venueName)),
              _infoRow('Date & Time', '$eventDate, $eventTime'),
              _infoRow('Location', eventLocation),
              const Divider(height: 32),

              _sectionTitle('Ticket Info'),
              _infoRow('Ticket No.', ticketNo),
              _infoRow(
                'Status',
                capitalize(registration.status),
                color: getStatusColor(registration.status),
              ),
              const Divider(height: 32),

              _sectionTitle('Invoice Details'),
              _infoRow('Invoice No.', invoiceNo),
              _infoRow('Serial No.', serialNo),
              const Divider(height: 32),

              _sectionTitle('Charges'),
              _amountRow('Ticket Price', ticketPrice),
              const SizedBox(height: 12),
              Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: _amountRow('Total', total, isBold: true),
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Thank you for your booking!',
                  style: TextStyle(fontSize: 16, color: Colors.pinkAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 14))),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(String label, double value, {bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
