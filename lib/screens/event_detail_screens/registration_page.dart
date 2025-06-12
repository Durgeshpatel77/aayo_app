import 'package:flutter/material.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example values
    const int approved = 50;
    const int pending = 10;
    const int declined = 5;
    const int waitlist = 8;
    const bool isRegistrationOpen = true;
    const int capacity = 100;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Registration status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isRegistrationOpen ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isRegistrationOpen ? Icons.lock_open : Icons.lock,
                      color: isRegistrationOpen ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isRegistrationOpen ? "Registration is OPEN" : "Registration is CLOSED",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isRegistrationOpen ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
        
              const SizedBox(height: 20),
        
              // Summary Grid (2 columns layout)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatusCard("Approved", Icons.check_circle, Colors.green, count: approved)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatusCard("Pending", Icons.hourglass_bottom, Colors.orange, count: pending)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatusCard("Declined", Icons.cancel, Colors.red, count: declined)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatusCard("Waiting List", Icons.access_time, Colors.deepPurple, count: waitlist)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatusCard("Capacity", Icons.people, Colors.pink, label: "$approved / $capacity")),
                    ],
                  ),
                ],
              ),
        
              const SizedBox(height: 24),
        
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, IconData icon, Color color, {int? count, String? label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold),
              ),
              Text(
                label ?? count.toString(),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
