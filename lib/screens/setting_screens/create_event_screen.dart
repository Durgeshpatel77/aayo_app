// screens/create_event_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


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
  final TextEditingController _onlineEventLinkController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();


  List<String> selectedCustomQuestions = [];
  bool showQuestionList = false;

  final List<String> addedQuestions = [];
  List<String> addedCustomQuestions = [];
  List<TextEditingController> _customQuestionControllers = [];




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
    _eventLocationController.dispose();
    _questionController.dispose();

    super.dispose();
  }

  // Helper method to show a SnackBar message to the user
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
  // void _resetEventForm() {
  //   _eventNameController.clear();
  //   _eventDescriptionController.clear();
  //   _manualVenueNameController.clear();
  //   _eventLandmarkController.clear();
  //   _onlineEventLinkController.clear();
  //   _eventLocationController.clear();
  //   _questionController.clear();
  //
  //   setState(() {
  //     selectedTags.clear();
  //     selectedCustomQuestions.clear(); // Clear your questions list
  //   });
  //
  //   final eventProvider = Provider.of<EventCreationProvider>(context, listen: false);
  //   eventProvider.setPickedEventImage(null);
  //   eventProvider.setStartDate(null);
  //   eventProvider.setStartTime(null);
  //   eventProvider.setEndDate(null);
  //   eventProvider.setEndTime(null);
  //   eventProvider.setTicketType('Free');
  //   eventProvider.setTicketPrice('');
  //   eventProvider.setSelectedVenueName(null);
  //   eventProvider.setUseManualVenueEntry(false);
  //   eventProvider.setCustomQuestion(''); // ✅ clear question string
  //
  //   debugPrint("✅ All form and provider data cleared.");
  // }

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
            TextfieldEditprofiile(
              controller: _eventLocationController,  // new controller for location input
              hintText: 'Enter location (e.g.,Delhi)',
              maxLength: 150,
              prefixIcon: Icons.location_on_outlined,
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
            GestureDetector(
              onTap: () async {
                final provider = Provider.of<EventCreationProvider>(context, listen: false);

                _questionController.text = provider.customQuestion; // Pre-fill

                String? enteredQuestion = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 20,),
                            Text(
                              'Enter Custom Question',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _questionController,
                              maxLength: 100,
                              decoration: InputDecoration(
                                hintText: 'Type your question...',

                                hintStyle: TextStyle(color: Colors.pink.shade500),
                                counterText: '', // Hide 0/100
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.pink.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.pink.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Cancel
                                  },
                                  child: Text('Cancel', style: TextStyle(color: Colors.black)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink.shade400,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, _questionController.text.trim());
                                  },
                                  child: const Text('Save',style: TextStyle(color: Colors.white),),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                if (enteredQuestion != null && enteredQuestion.isNotEmpty) {
                  provider.setCustomQuestion(enteredQuestion);
                  _questionController.clear(); // Optional: clear on save
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.pink, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Consumer<EventCreationProvider>(
                        builder: (context, provider, _) {
                          return Text(
                            provider.customQuestion.isNotEmpty
                                ? provider.customQuestion
                                : 'Select Custom Questions (optional)',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          );
                        },
                      ),
                    ),
                    Icon(Icons.add, color: Colors.grey.shade500, size: 22),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// Show full question list when expanded
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
                        focusColor: Colors.grey.shade400,
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
                List<String> selectedCustomQuestions = _customQuestionControllers
                    .map((c) => c.text.trim())
                    .where((q) => q.isNotEmpty)
                    .toList();

                debugPrint("📤 Custom questions to send: $selectedCustomQuestions");

                bool success = await eventProvider.createEvent(
                  context: context,
                  eventName: _eventNameController.text,
                  description: _eventDescriptionController.text,
                  venueAddress: _onlineEventLinkController.text,
                  venueName: 'Online Event',
                  tags: selectedTagTitles,
                  customQuestions: addedCustomQuestions, // ✅ Correct dynamic list
                  location: _eventLocationController.text,
                );

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🎉 Event created successfully!")),
                  );
                  Navigator.pop(context);
                }
                else {
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
                  ? FutureBuilder(
                future: Future.delayed(Duration(seconds: 10), () => 'timeout'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text('Timeout... Check Logs', style: TextStyle(color: Colors.red));
                  }
                  return CircularProgressIndicator(color: Colors.white);
                },
              )
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
                      if (_currentStep == 0) { // Step 0 validation
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
                      }
                      else if (_currentStep == 1) {
                        print("DEBUG: Step 1 Validation Running");
                        print("DEBUG: Location: ${_eventLocationController.text}");
                        print("DEBUG: Landmark: ${_eventLandmarkController.text}");
                        print("DEBUG: Venue (manual): ${_manualVenueNameController.text}");
                        print("DEBUG: Venue (selected): ${eventProvider.selectedVenueName}");
                        print("DEBUG: useManualVenueEntry: ${eventProvider.useManualVenueEntry}");

                        if (_eventLocationController.text.isNotEmpty &&
                            _eventLandmarkController.text.isNotEmpty &&
                            (eventProvider.useManualVenueEntry
                                ? _manualVenueNameController.text.isNotEmpty
                                : (eventProvider.selectedVenueName?.isNotEmpty ?? false))
                        ) {
                          canContinue = true;
                        } else {
                          _showMessage("Please enter Location, Landmark, and Venue Name. Use the switch if typing venue manually.");
                        }
                      }
                      else if (_currentStep == 2) { // Step 2 validation
                        if (_eventDescriptionController.text.isNotEmpty) {
                          canContinue = true;
                        } else {
                          _showMessage("Please enter the event description.");
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
                            location: _eventLocationController.text, // 🔴 NEW LINE
                            venueAddress: _eventLandmarkController.text,
                            venueName: eventProvider.useManualVenueEntry
                                ? _manualVenueNameController.text
                                : eventProvider.selectedVenueName ?? '',
                            tags: selectedTagTitles,
                            customQuestions: selectedCustomQuestions,
                          );

                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("🎉 Event created successfully!")),
                            );
                            Navigator.pop(context);
                          }
                          else {
                            print("DEBUG ERROR: ${eventProvider.errorMessage}");
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