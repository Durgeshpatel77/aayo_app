import 'package:flutter/material.dart';
import '../../models/create_event_model.dart';
import '../../models/event_model.dart'; // Import your EventModel

class UpdateEventScreen extends StatelessWidget {
  final EventModel eventModel;

  const UpdateEventScreen({super.key, required this.eventModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Edit event: ${eventModel.title}'),
        // TODO: Replace with full editable form fields
      ),
    );
  }
}
