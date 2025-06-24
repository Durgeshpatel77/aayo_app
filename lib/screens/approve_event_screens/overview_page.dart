import 'package:flutter/material.dart';
import '../../models/event_model.dart'; // Make sure you import your Event model

class OverviewTab extends StatelessWidget {
  final Event event;

  const OverviewTab({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    const int currentGuests = 50;
    const int maxGuests = 100;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.pink.shade100, // or any color you prefer
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade400,
                      ),
                ),
                const SizedBox(height: 20),
                _buildInfoTile(Icons.event, 'Event Name', event.title),
                _buildInfoTile(Icons.location_on, 'Location', event.location),
                _buildInfoTile(Icons.calendar_today, 'Start Date',
                    _formatDate(event.startTime)),
                _buildInfoTile(Icons.calendar_month, 'End Date',
                    _formatDate(event.endTime)),
                _buildInfoTile(Icons.people, 'Max Guests', '$maxGuests'),
                const SizedBox(height: 20),
                Divider(
                  color: Colors.pink.shade100,
                ),
                const SizedBox(height: 20),
                Text(
                  'Description',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  event.content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 20),
                Divider(
                  color: Colors.pink.shade100,
                ),
                const SizedBox(height: 20),
                Text(
                  'Guest Capacity',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildGuestCapacityBar(currentGuests, maxGuests, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.pink.shade300),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCapacityBar(int current, int max, BuildContext context) {
    final double fillPercentage = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$current Guests',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Text('Capacity: $max',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: fillPercentage,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
          ),
        ),
      ],
    );
  }
}
