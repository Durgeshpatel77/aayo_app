// screens/create_event_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../../models/create_event_model.dart'; // Ensure this path is correct
import '../../providers/setting_screens_providers/event_provider.dart'; // Ensure this path is correct
import '../../widgets/textfield _editprofiile.dart'; // Ensure this path is correct
import 'venue_list_page.dart'; // Import the new venue_list_page.dart, ensure path is correct

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // Controllers remain here as they are UI-specific
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _manualVenueNameController = TextEditingController();
  final TextEditingController _eventLandmarkController = TextEditingController();
  final TextEditingController _onlineEventLinkController = TextEditingController(); // New controller for online link
  final List<String> questionOptions = [
    "Social Profile",
    "Company Website",
    "LinkedIn",
    "Instagram",
    "Other"
  ];
  final List<String> predefinedQuestions = [
    "What is your Instagram ID?",
    "What is your Facebook ID?",
    "What is your LinkedIn profile?",
    "What is your GitHub username?",
    "What is your Email address?",
    "What is your Phone number?",
    "What is your Twitter handle?",
    "What is your current city?",
    "What is your occupation?"
  ];

  final List<String> addedQuestions = [];
  final List<String> selectedCustomQuestions = [];

  // All available tags for selection
  final List<Map<String, String>> allTags = [
    {'icon': '💼', 'title': 'Business'},
    {'icon': '🙌', 'title': 'Community'},
    {'icon': '🎵', 'title': 'Music & Entertainment'},
    {'icon': '🩹', 'title': 'Health'},
    {'icon': '🍟', 'title': 'Food & drink'},
    {'icon': '👨‍👩‍👧‍👦', 'title': 'Family & Education'},
    {'icon': '⚽', 'title': 'Sport'},
    {'icon': '👠', 'title': 'Fashion'},
    {'icon': '🎬', 'title': 'Film & Media'},
    {'icon': '🏠', 'title': 'Home & Lifestyle'},
    {'icon': '🎨', 'title': 'Design'},
    {'icon': '🎮', 'title': 'Gaming'},
    {'icon': '🧪', 'title': 'Science & Tech'},
    {'icon': '🏫', 'title': 'School & Education'},
    {'icon': '🏖️', 'title': 'Holiday'},
    {'icon': '✈️', 'title': 'Travel'},
  ];
  // List to hold currently selected tags
  List<Map<String, String>> selectedTags = [];

  // Stepper related state: tracks the current active step
  int _currentStep = 0;

  // New state variable to determine if the event is online or in-person
  bool _isOnlineEvent = false;

  @override
  void dispose() {
    // Dispose all TextEditingControllers to prevent memory leaks
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _manualVenueNameController.dispose();
    _eventLandmarkController.dispose();
    _onlineEventLinkController.dispose(); // Dispose new controller
    super.dispose();
  }
  void _showQuestionInputDialog(String label) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter question'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter your question'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                setState(() {
                  selectedCustomQuestions.add(_controller.text.trim());
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Helper method to show a SnackBar message to the user
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Handles the tap on the location selection field, showing a bottom sheet
  Future<void> _handleLocationTap() async {
    final eventProvider = Provider.of<EventCreationProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title for the bottom sheet
              const Text(
                'Choose Location Option',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Option to use current location
              ListTile(
                leading: const Icon(Icons.my_location, color: Colors.pink),
                title: const Text(
                  "Use Current Location",
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  final message = await eventProvider.getCurrentLocation(); // Call provider method
                  if (message != null) {
                    _showMessage(message); // Show success/error message
                  }
                },
              ),
              const Divider(),
              // Option to enter location manually
              ListTile(
                leading: const Icon(Icons.edit_location_alt,
                    color: Colors.deepPurple),
                title: const Text(
                  "Enter Location Manually",
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  final result = await eventProvider.showManualLocationPicker(context); // Call provider method
                  if (result != null && result.isNotEmpty) {
                    _showMessage("Selected Manual Location: ${result['display_name']}");
                  } else if (eventProvider.errorMessage != null) {
                    _showMessage(eventProvider.errorMessage!);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Handles navigation to the VenueListPage and processes the selected venue
  Future<void> _navigateToVenueList() async {
    final eventProvider = Provider.of<EventCreationProvider>(context, listen: false);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VenueListPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      // Check if the result contains 'venueName' or 'name' (from different selection flows)
      if (result.containsKey('venueName')) {
        eventProvider.setSelectedVenueName(result['venueName'] as String?);
        _manualVenueNameController.clear(); // Clear manual entry if venue is selected from list
        _showMessage('Selected Venue: ${eventProvider.selectedVenueName}');
      } else if (result.containsKey('name')) {
        eventProvider.setSelectedVenueName(result['name'] as String?);
        _manualVenueNameController.clear();
        _showMessage('Selected Venue: ${eventProvider.selectedVenueName}');
      }
    }
  }

  // Shows a modal bottom sheet for selecting event tags
  void _showTagSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to be full screen
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6, // Initial height of the sheet
          minChildSize: 0.4,     // Minimum height when dragged down
          maxChildSize: 1,      // Maximum height when dragged up
          builder: (context, scrollController) {
            return StatefulBuilder( // Use StatefulBuilder to update modal state
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Select Tags',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      /// Scrollable content for tags
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Wrap(
                            spacing: 10, // Horizontal spacing between chips
                            runSpacing: 10, // Vertical spacing between rows of chips
                            children: allTags.map((tag) {
                              final isSelected = selectedTags.any((t) => t['title'] == tag['title']);
                              return ChoiceChip(
                                label: Text(
                                  '${tag['icon']} ${tag['title']}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: Colors.pink,
                                backgroundColor: Colors.grey.shade200,
                                onSelected: (selected) {
                                  // Update the state of the parent widget (CreateEventScreen)
                                  setState(() {
                                    if (selected) {
                                      // Allow up to 3 tags to be selected
                                      if (!isSelected && selectedTags.length < 3) {
                                        selectedTags.add(tag);
                                      } else if (!isSelected && selectedTags.length >= 3) {
                                        // Show a message if more than 3 tags are attempted
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("You can select up to 3 tags only."),
                                            backgroundColor: Colors.redAccent,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      // Deselect tag
                                      selectedTags.removeWhere((t) => t['title'] == tag['title']);
                                    }
                                  });
                                  setModalState(() {}); // Update the state of the modal itself
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Fixed bottom "Done" button for the modal
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context), // Close the modal
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Done', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Helper Widget to build a consistent date/time selection row
  Widget _buildDateTimeRow({
    required BuildContext context,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onSelectDateTime,
    required String text,
    bool showTimeZone = false,
    String timeZone = '',
    required EventCreationProvider eventProvider, // Pass the provider to access formatTime
  }) {
    String displayText = text;
    if (date != null && time != null) {
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      displayText = '${DateFormat('dd/MM/yyyy').format(dt)} - ${eventProvider.formatTime(time)}';
    } else if (date != null) {
      displayText = DateFormat('dd/MM/yyyy').format(date);
    } else if (time != null) {
      displayText = eventProvider.formatTime(time);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayText,
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (showTimeZone && timeZone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Time Zone: $timeZone',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // Widget to build content for each step of the Stepper (for in-person events)
  Widget _buildStepContent(int stepIndex, EventCreationProvider eventProvider) {
    switch (stepIndex) {
      case 0: // Event Details Step
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image Picker
            GestureDetector(
              onTap: eventProvider.isPickingImage ? null : () async {
                final message = await eventProvider.pickImage();
                if (message != null) {
                  _showMessage(message);
                }
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink.shade400, width: 1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (eventProvider.pickedEventImage != null)
                      Positioned.fill(
                        child: Image.file(eventProvider.pickedEventImage!, fit: BoxFit.cover),
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 50,
                          color: Colors.pink.shade400,
                        ),
                      ),
                    if (eventProvider.isPickingImage)
                      const CircularProgressIndicator(color: Colors.pink),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Event Name Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextfieldEditprofiile(
                  controller: _eventNameController,
                  hintText: 'Enter event name',
                  maxLength: 30,
                  prefixIcon: Icons.celebration,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Start & End Date/Time Section
            Column(
              children: [
                _buildDateTimeRow(
                  context: context,
                  date: eventProvider.startDate,
                  time: eventProvider.startTime,
                  onSelectDateTime: () => eventProvider.selectStartDateTime(context),
                  text: 'Select Start Date & Time',
                  eventProvider: eventProvider,
                ),
                const SizedBox(height: 20),

                _buildDateTimeRow(
                  context: context,
                  date: eventProvider.endDate,
                  time: eventProvider.endTime,
                  onSelectDateTime: () async {
                    await eventProvider.selectEndDateTime(context);
                    if (eventProvider.errorMessage != null) {
                      _showMessage(eventProvider.errorMessage!);
                    }
                  },
                  text: 'Select End Date & Time',
                  eventProvider: eventProvider,
                ),
              ],
            ),
          ],
        );
      case 1: // Location Step
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location selection (current or manual)
            GestureDetector(
              onTap: eventProvider.isFetchingCurrentLocation ? null : _handleLocationTap,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Colors.pink.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Colors.pinkAccent, size: 24),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (eventProvider.selectedLocation?.isNotEmpty ?? false)
                                ? eventProvider.selectedLocation!
                                : 'Tap to select manual or current location',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'Offline location or virtual link',
                            style:
                            TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (eventProvider.isFetchingCurrentLocation)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.pink)),
                      )
                    else
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Landmark input field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextfieldEditprofiile(
                  controller: _eventLandmarkController,
                  hintText: 'Enter landmark',
                  maxLength: 30,
                  prefixIcon: Icons.apartment,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Toggle for manual venue entry or selection from list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Do you have venue ?',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Switch(
                  value: eventProvider.useManualVenueEntry,
                  onChanged: (bool value) {
                    eventProvider.setUseManualVenueEntry(value);
                    if (value) {
                      eventProvider.setSelectedVenueName(null); // Clear selected venue if switching to manual
                      _manualVenueNameController.clear();
                    }
                  },
                  activeColor: Colors.pink,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Conditional rendering for manual venue input or venue list selection
            eventProvider.useManualVenueEntry
                ?
            TextfieldEditprofiile(
              controller: _manualVenueNameController,
              hintText: 'Enter venue name (type...)',
              maxLength: 30,
              prefixIcon: Icons.meeting_room_outlined,
            )
                : GestureDetector(
              onTap: _navigateToVenueList, // Navigate to venue list page
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      width: 1, color: Colors.pink.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.meeting_room_outlined,
                        color: Colors.pinkAccent, size: 24),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        (eventProvider.selectedVenueName?.isNotEmpty ?? false)
                            ? eventProvider.selectedVenueName!
                            : 'Select Venue from List',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ],
        );
      case 2: // Description, Tags, and Tickets Step
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Description input field
            TextField(
              controller: _eventDescriptionController,
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
            const SizedBox(height: 20),
            Text(
              "Add Custom Questions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Wrap(
              spacing: 8,
              children: questionOptions.map((option) {
                return ActionChip(
                  label: Text(option),
                  backgroundColor: Colors.pink.shade50,
                  onPressed: () {
                    _showQuestionInputDialog(option);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            ...selectedCustomQuestions.map((q) => ListTile(
              leading: const Icon(Icons.question_answer, color: Colors.pink),
              title: Text(q),
            )).toList(),

            const SizedBox(height: 20),
            // Tag selection field
            GestureDetector(
              onTap: _showTagSelector, // Open tag selection modal
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.pink.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedTags.isEmpty
                            ? "Select tags from list"
                            : selectedTags.map((tag) => tag['title']).join(', '),
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey.shade500,size: 14,),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tickets Section (Free/Paid dropdown and price input)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                    Border.all(width: 1, color: Colors.pink.shade400),
                  ),

                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined,
                          color: Colors.pinkAccent, size: 24),
                      const SizedBox(width: 15),
                      const Text(
                        'Tickets',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: eventProvider.ticketType,
                        underline: const SizedBox(),
                        items: ['Free', 'Paid']
                            .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                            .toList(),
                        onChanged: (value) {
                          eventProvider.setTicketType(value!);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Conditional Widgets for Ticket Price based on selection
                if (eventProvider.ticketType == 'Paid')
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter ticket price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.pink.shade400, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.pink.shade400, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.pink.shade400, width: 1),
                      ),
                    ),
                    onChanged: (value) {
                      eventProvider.setTicketPrice(value);
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'This is a Free Event',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink(); // Fallback for unexpected step index
    }
  }

  // New method for building the online event form
  Widget _buildOnlineEventForm(EventCreationProvider eventProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image Picker
          GestureDetector(
            onTap: eventProvider.isPickingImage ? null : () async {
              final message = await eventProvider.pickImage();
              if (message != null) {
                _showMessage(message);
              }
            },
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink.shade400, width: 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (eventProvider.pickedEventImage != null)
                    Positioned.fill(
                      child: Image.file(eventProvider.pickedEventImage!, fit: BoxFit.cover),
                    )
                  else
                    Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 50,
                        color: Colors.pink.shade400,
                      ),
                    ),
                  if (eventProvider.isPickingImage)
                    const CircularProgressIndicator(color: Colors.pink),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Event Name Field
          TextfieldEditprofiile(
            controller: _eventNameController,
            hintText: 'Enter event name',
            maxLength: 30,
            prefixIcon: Icons.celebration,
          ),
          const SizedBox(height: 20),

          // Start & End Date/Time Section
          _buildDateTimeRow(
            context: context,
            date: eventProvider.startDate,
            time: eventProvider.startTime,
            onSelectDateTime: () => eventProvider.selectStartDateTime(context),
            text: 'Select Start Date & Time',
            eventProvider: eventProvider,
          ),
          const SizedBox(height: 20),

          _buildDateTimeRow(
            context: context,
            date: eventProvider.endDate,
            time: eventProvider.endTime,
            onSelectDateTime: () async {
              await eventProvider.selectEndDateTime(context);
              if (eventProvider.errorMessage != null) {
                _showMessage(eventProvider.errorMessage!);
              }
            },
            text: 'Select End Date & Time',
            eventProvider: eventProvider,
          ),
          const SizedBox(height: 20),

          // Online Event Link
          TextfieldEditprofiile(
            controller: _onlineEventLinkController,
            hintText: 'Enter Online Event Link (e.g., Zoom, Google Meet)',
            prefixIcon: Icons.link,
          ),
          const SizedBox(height: 20),

          // Event Description
          TextField(
            controller: _eventDescriptionController,
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
          const SizedBox(height: 20),

          // Removed "Add Custom Questions" section

          // Tag selection field
          GestureDetector(
            onTap: _showTagSelector, // Open tag selection modal
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pink.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedTags.isEmpty
                          ? "Select tags from list"
                          : selectedTags.map((tag) => tag['title']).join(', '),
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey.shade500,size: 14,),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Removed "Tickets" section

          const SizedBox(height: 30),

          // Submit Button for online event
          SizedBox(
            width: double.infinity,
            child:
            ElevatedButton(
              onPressed: eventProvider.isLoading ? null : () async {
                // Validation for online event form
                if (_eventNameController.text.isEmpty ||
                    eventProvider.pickedEventImage == null ||
                    eventProvider.startDate == null ||
                    eventProvider.startTime == null ||
                    eventProvider.endDate == null ||
                    eventProvider.endTime == null ||
                    _onlineEventLinkController.text.isEmpty ||
                    _eventDescriptionController.text.isEmpty) {
                  _showMessage("Please fill all required fields.");
                  return;
                }

                final List<String> selectedTagTitles =
                selectedTags.map((tag) => tag['title']!.replaceAll('"', '')).toList();

                debugPrint("🟢 Cleaned Tags to Send: $selectedTagTitles");

                bool success = await eventProvider.createEvent(
                  context: context,
                  eventName: _eventNameController.text,
                  description: _eventDescriptionController.text,
                  venueAddress: _onlineEventLinkController.text,
                  venueName: 'Online Event',
                  tags: selectedTagTitles, customQuestions: [],
                );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🎉 Event created successfully!")),
                  );
                  Navigator.pop(context);
                } else {
                  _showMessage(eventProvider.errorMessage ?? "Something went wrong.");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: eventProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Event'),
            ),
          ),
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to changes in EventCreationProvider
    return Consumer<EventCreationProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            scrolledUnderElevation: 0,
            title: const Text("Create an event"),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context); // Navigate back
                },
                child: const Icon(Icons.arrow_back_ios_new_sharp)),
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Online/In-person selection at the top, outside the conditional
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ChoiceChip(
                      label: const Text('Online Event'),
                      selected: _isOnlineEvent,
                      onSelected: (selected) {
                        setState(() {
                          _isOnlineEvent = selected;
                          // Clear all relevant state when switching to online
                          if (_isOnlineEvent) {
                            eventProvider.clearAllEventData(); // New method in provider
                            _eventNameController.clear();
                            _eventDescriptionController.clear();
                            _manualVenueNameController.clear();
                            _eventLandmarkController.clear();
                            selectedTags.clear();
                            addedQuestions.clear();
                            // _onlineEventLinkController will be used here
                          } else {
                            // Clear online link field if switching to in-person
                            _onlineEventLinkController.clear();
                          }
                          // Reset stepper if switching from online to in-person
                          _currentStep = 0;
                        });
                      },
                      selectedColor: Colors.pink.shade100,
                    ),
                    ChoiceChip(
                      label: const Text('In-person Event'),
                      selected: !_isOnlineEvent,
                      onSelected: (selected) {
                        setState(() {
                          _isOnlineEvent = !selected; // If "In-person" is selected, _isOnlineEvent is false
                          // Clear all relevant state when switching to in-person
                          if (!_isOnlineEvent) {
                            eventProvider.clearAllEventData(); // New method in provider
                            _eventNameController.clear();
                            _eventDescriptionController.clear();
                            _onlineEventLinkController.clear();
                            selectedTags.clear();
                            addedQuestions.clear();
                            // _manualVenueNameController and _eventLandmarkController will be used here
                          } else {
                            // Clear location-related fields if switching to online
                            eventProvider.setSelectedVenueName(null);
                            _manualVenueNameController.clear();
                            _eventLandmarkController.clear();
                          }
                          // Reset stepper if switching from in-person to online (though stepper won't be visible)
                          _currentStep = 0;
                        });
                      },
                      selectedColor: Colors.pink.shade100,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isOnlineEvent
                    ? _buildOnlineEventForm(eventProvider) // Direct form for online events
                    : Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.pink, // 🔴 This changes the stepper line & icon color
                    ),
                  ),
                  child: Stepper(
                    type: StepperType.vertical, // Vertical stepper layout
                    currentStep: _currentStep, // Controls the active step
                    onStepContinue: () async {
                      // Validation logic for each step before proceeding
                      bool canContinue = false;
                      if (_currentStep == 0) { // Validation for Event Details step
                        // Base validation for event details
                        if (_eventNameController.text.isNotEmpty &&
                            eventProvider.pickedEventImage != null &&
                            eventProvider.startDate != null &&
                            eventProvider.startTime != null &&
                            eventProvider.endDate != null &&
                            eventProvider.endTime != null) {
                          canContinue = true;
                        } else {
                          _showMessage("Please fill all event details, select an image, and set start/end times.");
                        }
                      } else if (_currentStep == 1) { // Validation for Location step
                        if ((eventProvider.selectedLocation?.isNotEmpty ?? false) &&
                            (_eventLandmarkController.text.isNotEmpty) &&
                            (eventProvider.useManualVenueEntry ? _manualVenueNameController.text.isNotEmpty : eventProvider.selectedVenueName?.isNotEmpty ?? false)
                        ) {
                          canContinue = true;
                        } else {
                          _showMessage("Please select a location, enter a landmark, and specify a venue.");
                        }
                      } else if (_currentStep == 2) { // Validation for Description, Tags, Tickets
                        if (_eventDescriptionController.text.isEmpty) {
                          _showMessage("Please enter the event description.");
                        } else {
                          canContinue = true;
                        }
                      }

                      if (canContinue) {
                        if (_currentStep < 2) {
                          setState(() {
                            _currentStep += 1;
                          });
                        } else {
                          // Final step: Submit event
                          final List<String> selectedTagTitles =
                          selectedTags.map((tag) => tag['title']!.replaceAll('"', '')).toList();

                          debugPrint("🟢 Cleaned Tags to Send: $selectedTagTitles");

                          debugPrint("🟣 Selected Tags: $selectedTagTitles");

                          bool success = await eventProvider.createEvent(
                            context: context,
                            eventName: _eventNameController.text,
                            description: _eventDescriptionController.text,
                            venueAddress: _eventLandmarkController.text, // For in-person
                            venueName: eventProvider.useManualVenueEntry
                                ? _manualVenueNameController.text
                                : eventProvider.selectedVenueName ?? '',
                            tags: selectedTagTitles,
                            customQuestions: selectedCustomQuestions, // ✅ optional

                          );

                            if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("🎉 Event created successfully!")),
                            );
                            Navigator.pop(context);
                          } else {
                            _showMessage(eventProvider.errorMessage ?? "Something went wrong.");
                          }
                        }
                      }
                    },
                    onStepCancel: () {
                      // Handle going back a step or popping the screen
                      if (_currentStep > 0) {
                        setState(() {
                          _currentStep -= 1;
                        });
                      } else {
                        Navigator.pop(context); // Go back if on the first step
                      }
                    },
                    steps: [
                      // Step 0: Event Details
                      Step(
                        title: const Text('Event Details'),
                        content: _buildStepContent(0, eventProvider),
                        isActive: _currentStep >= 0, // Active if current step is 0 or greater
                        state: _currentStep > 0 ? StepState.complete : StepState.indexed, // Mark as complete if moved past
                      ),
                      // Step 1: Location
                      Step(
                        title: const Text('Location'),
                        content: _buildStepContent(1, eventProvider),
                        isActive: _currentStep >= 1, // Active if current step is 1 or greater
                        state: _currentStep > 1 ? StepState.complete : StepState.indexed, // Mark as complete if moved past
                      ),
                      // Step 2: Description & Tickets
                      Step(
                        title: const Text('Description & Tickets'),
                        content: _buildStepContent(2, eventProvider),
                        isActive: _currentStep >= 2, // Active if current step is 2 or greater
                        state: _currentStep == 2 ? StepState.editing : StepState.indexed, // Mark as editing if current step
                      ),
                    ],
                    // Custom controls for the stepper (Continue/Back buttons)
                    controlsBuilder: (BuildContext context, ControlsDetails details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: details.onStepContinue, // Calls onStepContinue callback
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: eventProvider.isLoading && _currentStep == 2 // Show loading only on final step
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(_currentStep == 2 ? 'Create Event' : 'Continue'), // Button text changes on last step
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Show "Back" button only if not on the first step
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: details.onStepCancel, // Calls onStepCancel callback
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.pink,
                                    side: const BorderSide(color: Colors.pink),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Back'),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}