// screens/CreateEventScreen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/Create_Event_model.dart';
import '../providers/event_provider.dart';
import '../widgets/TextField _editprofiile.dart'; // For date formatting

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  File? _pickedEventImage;
  String _ticketType = 'Free'; // default value
  String _ticketPrice = '';

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventLocationController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();

  // For Date and Time Pickers
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  bool _requireApproval = false; // State for the toggle switch
  String? selectedLocation;

  // --- Image Picking Function ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedEventImage = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event cover image picked!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selection cancelled.')),
      );
    }
  }
  // --- Date Picking Functions ---
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.pink,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.pink),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      // Prompt for start time immediately
    }
  }
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.pink,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.pink),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (_startDate != null && picked.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date can’t be before start date')),
        );
        return;
      }

      setState(() {
        _endDate = picked;
      });
    }
  }
  // --- Time Picking Functions ---
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              // Use dark theme for time picker
              primary: Colors.pink, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.white, // numbers and AM/PM
              surface: Color(0xFF2C2C2E), // clock face background
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.pink,
              onPrimary: Colors.white,
              onSurface: Colors.white,
              surface: Colors.grey,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  // Helper to format TimeOfDay
  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt); // e.g., 11:00 PM
  }

  // Helper to get formatted local GMT offset (e.g., "GMT+05:30")
  String _getGmtOffset() {
    final Duration offset = DateTime.now().timeZoneOffset;
    final String sign = offset.isNegative ? '-' : '+';
    final int hours = offset.abs().inHours;
    final int minutes = offset.abs().inMinutes % 60;
    return 'GMT$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventLocationController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

//help to select location  manually or  currant location.
  Future<void> _handleLocationTap() async {
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
                  await _getCurrentLocation();
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
                onTap: () {
                  Navigator.pop(context);
                  _showManualLocationPicker();
                },
              ),
            ],
          ),
        );
      },
    );
  }

//take permission when you enter 1st time
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage('Location permissions are permanently denied.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    String address =
        '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

    setState(() {
      selectedLocation = address;
    });

    _showMessage('Selected: $address');
  }

// after click on manually show dialog box from hire
  Future<void> _showManualLocationPicker() async {
    TextEditingController _searchController = TextEditingController();
    List<Map<String, dynamic>> _suggestions = [];
    bool _isLoading = false;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          // debounce timer to limit API calls
          Timer? _debounce;

          void _onSearchChanged(String value) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();

            _debounce = Timer(const Duration(milliseconds: 500), () async {
              if (value.isNotEmpty) {
                setState(() => _isLoading = true);
                try {
                  final results = await _fetchLocationSuggestions(value);
                  setState(() {
                    _suggestions = results;
                    _isLoading = false;
                  });
                } catch (e) {
                  setState(() {
                    _suggestions = [];
                    _isLoading = false;
                  });
                }
              } else {
                setState(() {
                  _suggestions.clear();
                  _isLoading = false;
                });
              }
            });
          }

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              height: 700,
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          hintText: 'Search location...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.pink.shade400, width: 1),
                          ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.pink.shade400, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.pink.shade400, width: 1),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  Expanded(
                    child: !_isLoading && _suggestions.isEmpty
                        ? const Center(child: Text("Search for a location"))
                        : ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return ListTile(
                                title: Text(suggestion['display_name']),
                                onTap: () {
                                  Navigator.pop(
                                      context, suggestion['display_name']);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedLocation = result;
      });
      _showMessage("Selected: $result");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLocationSuggestions(
      String query) async {
    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1');

    final response = await http.get(uri, headers: {
      'User-Agent': 'Flutter App',
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      return [];
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically get GMT offset and time zone name (e.g., IST)
    final String gmtOffset = _getGmtOffset();
    final String timeZoneName = DateTime.now().timeZoneName;
    final String timeZoneDisplay =
        '$gmtOffset\n$timeZoneName'; // Example: GMT+05:30\nIST

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0, //same color when scroll page
        title: Text("Create an event"),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new_sharp)),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Custom Header (Personal Calendar / Public) ---
            const SizedBox(height: 20),

            // --- Event Image Picker (Now occupies full width in this section) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.pink.shade400, width: 1),
                    image: _pickedEventImage != null
                        ? DecorationImage(
                            image: FileImage(_pickedEventImage!),
                            fit: BoxFit.cover,
                          )
                        : null, // Don't set image if null, so we can overlay icon instead
                  ),
                  child: _pickedEventImage == null
                      ? Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 50,
                            color: Colors.pink.shade400,
                          ),
                        )
                      : null,
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
                    prefixIcon: Icons.person,
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
                    date: _startDate,
                    time: _startTime,
                    onSelectDate: () => _selectStartDate(context),
                    onSelectTime: () => _selectStartTime(context),
                    text: 'Select Start Date & time',
                  ),
                  const SizedBox(height: 20),

                  _buildDateTimeRow(
                    context: context,
                    date: _endDate,
                    time: _endTime,
                    onSelectDate: () => _selectEndDate(context), // Fix this
                    onSelectTime: () => _selectEndTime(context), // Fix this
                    text: 'Select End Date & Time',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Add Event Location ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GestureDetector(
                onTap: _handleLocationTap,
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
                          color: Colors.black, size: 24),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (selectedLocation?.isNotEmpty ?? false)
                                  ? selectedLocation!
                                  : 'No location selected',
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
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Add Description ---
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Description tapped!')),
                    );
                  },
                  maxLines: 5, // allows multi-line input
                  decoration: InputDecoration(
                    hintText: 'Add Description',
                    hintStyle: TextStyle(
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
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )),
            const SizedBox(height: 20),

            // --- Event Options List ---
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
                        Icon(Icons.confirmation_number_outlined,
                            color: Colors.black, size: 24),
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
                          value: _ticketType,
                          underline: const SizedBox(),
                          items: ['Free', 'Paid']
                              .map((type) => DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _ticketType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Conditional Widgets
                  if (_ticketType == 'Paid')
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ticket Price',
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
                        setState(() {
                          _ticketPrice = value;
                        });
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
                          left: 8.0), // space between buttons
                      child: ElevatedButton(
                        onPressed: () {
                          final newEvent = EventModel(
                            name: _eventNameController.text,
                            startDate: _startDate,
                            startTime: _startTime,
                            endDate: _endDate,
                            endTime: _endTime,
                            location: selectedLocation,
                            description: 'Some description', // if you capture it
                            ticketType: _ticketType,
                            ticketPrice: _ticketType == 'Paid' ? _ticketPrice : null,
                            image: _pickedEventImage,
                          );

                          Provider.of<EventCreationProvider>(context, listen: false)
                              .addEvent(newEvent);

                          Navigator.pop(context); // Go back to event list page or your event tab
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event created!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Event',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget for Date/Time Rows ---
  Widget _buildDateTimeRow({
    required BuildContext context,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onSelectDate,
    required VoidCallback onSelectTime,
    required String text,
    bool showTimeZone = false,
    String timeZone = '',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.pink.shade400, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              onSelectDate();
              onSelectTime();
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  date != null && time != null
                      ? '${date.day}/${date.month}/${date.year} ${time.format(context)}'
                      : text,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          if (showTimeZone && timeZone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Time Zone: $timeZone',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // --- Helper Widget for Event Option Rows ---
  Widget _buildEventOptionRow({
    required IconData icon,
    required String label,
    String? value,
    bool showLinkIcon = false,
    bool hasSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1, color: Colors.pink.shade400)),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (value != null)
              Text(
                value,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            if (showLinkIcon)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.link, color: Colors.grey[400], size: 20),
              ),
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: Colors.pink,
              ),
          ],
        ),
      ),
    );
  }
}
