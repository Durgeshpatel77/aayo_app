import 'package:aayo/screens/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:aayo/providers/onboarding_provider.dart';
import 'package:intl/intl.dart';

class Addeventsscreen extends StatefulWidget {
  const Addeventsscreen({super.key});

  @override
  State<Addeventsscreen> createState() => _AddeventsscreenState();
}

class _AddeventsscreenState extends State<Addeventsscreen> {
  File? _tempPickedImage;
  final TextEditingController _postController = TextEditingController();
  DateTime? scheduledDateTime;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _tempPickedImage = File(pickedFile.path);
      });
      Provider.of<ImageSelectionProvider>(context, listen: false).setImage(_tempPickedImage);
    } else {
      Provider.of<ImageSelectionProvider>(context, listen: false).setImage(null);
    }
  }

  Future<void> _scheduleLater() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          scheduledDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  bool get isPostEnabled {
    return (_tempPickedImage != null || _postController.text.trim().isNotEmpty || scheduledDateTime != null);
  }

  void _submitEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(scheduledDateTime != null
            ? 'Event scheduled for ${DateFormat.yMMMd().add_jm().format(scheduledDateTime!)}'
            : 'Event Posted!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.03),

            Row(
              children: [
                CircleAvatar(
                  backgroundImage: const NetworkImage('https://randomuser.me/api/portraits/men/75.jpg'),
                  radius: screenWidth * 0.065,
                ),
                SizedBox(width: screenWidth * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("John Doe", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
                    Text("Event Organizer", style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.03)),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),

            if (scheduledDateTime != null) ...[
              Text(
                "Scheduled for: ${DateFormat.yMMMd().add_jm().format(scheduledDateTime!)}",
                style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600, fontSize: screenWidth * 0.035),
              ),
              SizedBox(height: screenHeight * 0.01),
            ],

            TextField(
              controller: _postController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What's the event about?",
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),

            if (_tempPickedImage != null) ...[
              SizedBox(height: screenHeight * 0.02),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    child: Image.file(
                      _tempPickedImage!,
                      width: double.infinity,
                      height: screenHeight * 0.25,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 16),
                        onPressed: () {
                          setState(() {
                            _tempPickedImage = null;
                          });
                          Provider.of<ImageSelectionProvider>(context, listen: false).setImage(null);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: screenHeight * 0.02),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo, size: screenWidth * 0.045),
                  label: Text("Gallery", style: TextStyle(fontSize: screenWidth * 0.03)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade50,
                    foregroundColor: Colors.pink,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt, size: screenWidth * 0.045),
                  label: Text("Camera", style: TextStyle(fontSize: screenWidth * 0.03)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade50,
                    foregroundColor: Colors.pink,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  CreateEventScreen()));
                  },
                  icon: Icon(Icons.event, size: screenWidth * 0.045),
                  label: Text("Event", style: TextStyle(fontSize: screenWidth * 0.03)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade50,
                    foregroundColor: Colors.pink,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _scheduleLater,
                  icon: Icon(Icons.schedule, color: Colors.grey, size: screenWidth * 0.055),
                  tooltip: "Schedule Event",
                ),
                SizedBox(
                  //height: screenHeight * 0.05,
                  child: ElevatedButton(
                    onPressed: isPostEnabled ? _submitEvent : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPostEnabled ? Colors.pink : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                    ),
                    child: Text(
                      scheduledDateTime != null ? 'Schedule' : 'Post',
                      style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
