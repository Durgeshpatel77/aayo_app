// screens/create_event_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../../models/create_event_model.dart';
import '../../providers/setting_screens_providers/event_provider.dart';
import '../../widgets/textfield _editprofiile.dart';
import 'venue_list_page.dart'; // Import the new venue_list_page.dart

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
  List<Map<String, String>> selectedTags = [];

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _manualVenueNameController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // New _handleLocationTap that uses provider methods
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
              const Text(
                'Choose Location Option',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.my_location, color: Colors.pink),
                title: const Text(
                  "Use Current Location",
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final message = await eventProvider.getCurrentLocation();
                  if (message != null) {
                    _showMessage(message);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit_location_alt,
                    color: Colors.deepPurple),
                title: const Text(
                  "Enter Location Manually",
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await eventProvider.showManualLocationPicker(context);
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

  // New _navigateToVenueList that uses provider methods
  Future<void> _navigateToVenueList() async {
    final eventProvider = Provider.of<EventCreationProvider>(context, listen: false);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VenueListPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      if (result.containsKey('venueName')) {
        eventProvider.setSelectedVenueName(result['venueName'] as String?);
        _manualVenueNameController.clear(); // Clear manual entry if venue is selected from list
        _showMessage('Selected Venue: ${eventProvider.selectedVenueName}');
      } else if (result.containsKey('name')) { // This is for selecting from the list directly
        eventProvider.setSelectedVenueName(result['name'] as String?);
        _manualVenueNameController.clear();
        _showMessage('Selected Venue: ${eventProvider.selectedVenueName}');
      }
    }
  }

  void _showTagSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 1,
          builder: (context, scrollController) {
            return StatefulBuilder(
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

                      /// Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
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
                                  setState(() {
                                    if (selected) {
                                      if (!isSelected && selectedTags.length < 3) {
                                        selectedTags.add(tag);
                                      } else if (!isSelected && selectedTags.length >= 3) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("You can select up to 3 tags only."),
                                            backgroundColor: Colors.redAccent,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      selectedTags.removeWhere((t) => t['title'] == tag['title']);
                                    }
                                  });
                                  setModalState(() {}); // update modal state
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Fixed bottom "Done" button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
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
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios_new_sharp)),
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --- Event Image Picker ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
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
                ),
                const SizedBox(height: 20),

                // --- Event Name Field ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
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
                ),
                const SizedBox(height: 20),

                // --- Start & End Date/Time Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
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
                ),
                const SizedBox(height: 20),

                // --- Add Event Location - Manual/Current is REQUIRED ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                eventProvider.setSelectedVenueName(null);
                                _manualVenueNameController.clear();
                              } else {
                                // Handled internally by the provider's setUseManualVenueEntry
                              }
                            },
                            activeColor: Colors.pink,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      eventProvider.useManualVenueEntry
                          ?
                      TextfieldEditprofiile(
                        controller: _manualVenueNameController,
                        hintText: 'Enter venue name (type...)',
                        maxLength: 30,
                        prefixIcon: Icons.meeting_room_outlined,
                      )
                          : GestureDetector(
                        onTap: _navigateToVenueList,
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
                  ),
                ),
                const SizedBox(height: 20),
                // --- Add Description ---
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
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
                    )),
                const SizedBox(height: 20),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child:
                    GestureDetector(
                      onTap: _showTagSelector,
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
                    )
                ),

                const SizedBox(height: 20),

                // --- Event Options List (Tickets Section) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
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

                      // Conditional Widgets for Ticket Price
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
                ),

                // --- Create Event Button ---
                const SizedBox(height: 5),

                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0),
                          child: ElevatedButton(
                            onPressed: eventProvider.isLoading ? null : () async {
                              // No need for detailed validation here, provider handles it.
                              // Pass controller texts to the provider.
                              bool success = await eventProvider.createEvent(
                                context: context, // <-- ADD this
                                eventName: _eventNameController.text,
                                description: _eventDescriptionController.text,
                                venueAddress: _eventLandmarkController.text, // This is the landmark
                                venueName: eventProvider.useManualVenueEntry
                                    ? _manualVenueNameController.text
                                    : eventProvider.selectedVenueName ?? '',

                              );

                              if (success) {
                                _showMessage('Event created successfully!');
                                Navigator.pop(context);
                              } else {
                                _showMessage('Failed to create event. ${eventProvider.errorMessage}');
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
                                : const Text(
                              'Create Event',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widget for Date/Time Rows ---
  Widget _buildDateTimeRow({
    required BuildContext context,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onSelectDateTime,
    required String text,
    bool showTimeZone = false,
    String timeZone = '',
    required EventCreationProvider eventProvider, // Pass the provider
  }) {
    String displayText = text;
    if (date != null && time != null) {
      final now = DateTime.now();
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
}