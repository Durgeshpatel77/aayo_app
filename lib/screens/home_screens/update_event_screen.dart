import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/create_event_model.dart';
import '../../models/event_model.dart';
import '../../widgets/textfield _editprofiile.dart'; // Your styled text field

class UpdateEventScreen extends StatefulWidget {
  final EventModel eventData;

  const UpdateEventScreen({super.key, required this.eventData});

  @override
  State<UpdateEventScreen> createState() => _UpdateEventScreenState();
}

class _UpdateEventScreenState extends State<UpdateEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _venueNameController;
  late TextEditingController _venueAddressController;

  late DateTime _startDateTime;
  late DateTime _endDateTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final details = widget.eventData.eventDetails!;
    _titleController = TextEditingController(text: widget.eventData.title);
    _locationController = TextEditingController(text: details.location);
    _descriptionController = TextEditingController(text: widget.eventData.content);
    _venueNameController = TextEditingController(text: details.venueName ?? '');
    _venueAddressController = TextEditingController(text: details.venueAddress ?? '');
    _startDateTime = details.startTime;
    _endDateTime = details.endTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _venueNameController.dispose();
    _venueAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initialDate = isStart ? _startDateTime : _endDateTime;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: Colors.pink,
            colorScheme: ColorScheme.dark(
              primary: Colors.pink,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              timePickerTheme: TimePickerThemeData(
                dialHandColor: Colors.pink,
                hourMinuteTextColor: Colors.white,
                backgroundColor: Colors.black,
                dialBackgroundColor: Colors.grey.shade900,
              ),
              colorScheme: ColorScheme.dark(
                primary: Colors.pink,
                surface: Colors.black,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final selected = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStart) {
            _startDateTime = selected;
          } else {
            _endDateTime = selected;
          }
        });
      }
    }
  }

  Future<void> _updateEvent() async {
    setState(() {
      _isLoading = true;
    });

    final details = widget.eventData.eventDetails!;
    final updatedEvent = {
      "type": "event",
      "user": widget.eventData.user.id,
      "title": _titleController.text.trim(),
      "content": _descriptionController.text.trim(),
      "location": _locationController.text.trim(),
      "city": details.city,
      "latitude": details.latitude,
      "longitude": details.longitude,
      "startTime": _startDateTime.toIso8601String(),
      "endTime": _endDateTime.toIso8601String(),
      "description": _descriptionController.text.trim(),
      "isFree": details.isFree,
      "price": details.price,
      "venueName": _venueNameController.text.trim(),
      "venueAddress": _venueAddressController.text.trim(),
      "tags": "software",
      "customQuestions": "What your insta Id?, whats linked id?",
    };

    final url = 'http://82.29.167.118:8000/api/post/event/${widget.eventData.id}';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedEvent),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Event updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        print('❌ Response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to update event')),
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error occurred during update')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Update Event'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_sharp),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink,))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextfieldEditprofiile(
              controller: _titleController,
              hintText: 'Enter event Name',
              prefixIcon: Icons.celebration,
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: _locationController,
              hintText: 'Enter location',
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: _venueNameController,
              hintText: 'Enter venue name',
              prefixIcon: Icons.meeting_room_outlined,
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: _venueAddressController,
              hintText: 'Enter landmark',
              prefixIcon: Icons.apartment,
            ),
            const SizedBox(height: 20),
            _buildDateTimeRow(
              context: context,
              date: _startDateTime,
              onSelectDateTime: () => _pickDateTime(true),
            ),

            _buildDateTimeRow(
              context: context,
              date: _endDateTime,
              onSelectDateTime: () => _pickDateTime(false),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Add Description',
                hintStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  BorderSide(width: 1, color: Colors.pink.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  BorderSide(width: 1, color: Colors.pink.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  BorderSide(width: 1, color: Colors.pink.shade700),
                ),
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Event',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget _buildDateTimeRow({
  required BuildContext context,
  required DateTime date,
  required VoidCallback onSelectDateTime,
}) {
  final formattedDate = '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
  final formattedTime = TimeOfDay.fromDateTime(date).format(context);

  final displayText = '$formattedDate - $formattedTime';

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.pink.shade400, width: 1),
    ),
    child: GestureDetector(
      onTap: onSelectDateTime,
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: Colors.pink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(displayText, style: const TextStyle(fontSize: 15)),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    ),
  );
}
