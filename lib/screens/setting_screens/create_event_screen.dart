// screens/create_event_screen.dart
import 'dart:async';
import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // For json decoding


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
  File? _pickedEventImage;
  String _ticketType = 'Free'; // default value
  String _ticketPrice = '';

  // Single source of truth for the event's location (manual or current)
  String? selectedLocation;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedCity;

  // State variables for Venue selection
  bool _useManualVenueEntry = false; // true for manual text input, false for venue list
  String? _selectedVenueName; // Stores venue name from VenueListPage
  final TextEditingController _manualVenueNameController = TextEditingController(); // Controller for manual venue input


  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();

  // For Date and Time Pickers
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  // Loading state variables
  bool _isCreatingEvent = false;
  bool _isFetchingLocation = false;
  bool _isPickingImage = false;


  // --- Image Picking Function ---
  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
    });
    try {
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
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  // --- Date Picking Functions ---
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
      setState(() {
        _startDate = picked;
      });
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
            colorScheme: const ColorScheme.dark(
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
            colorScheme: const ColorScheme.dark(
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

  // New combined functions for selecting both date and time
  Future<void> _selectStartDateTime(BuildContext context) async {
    await _selectStartDate(context); // Select date first
    if (_startDate != null) { // Only proceed to time if date was picked
      await _selectStartTime(context); // Then select time
    }
  }

  Future<void> _selectEndDateTime(BuildContext context) async {
    await _selectEndDate(context); // Select date first
    if (_endDate != null) { // Only proceed to time if date was picked
      await _selectEndTime(context); // Then select time
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _manualVenueNameController.dispose();
    super.dispose();
  }

  //help to select location manually or currant location.
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
    setState(() {
      _isFetchingLocation = true;
    });
    try {
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
          '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

      setState(() {
        selectedLocation = address;
        _selectedLatitude = position.latitude;
        _selectedLongitude = position.longitude;
        _selectedCity = place.locality; // Get city from placemark
      });

      _showMessage('Selected Current Location: $address');
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  // after click on manually show dialog box from hire
  Future<void> _showManualLocationPicker() async {
    TextEditingController _searchController = TextEditingController();
    List<Map<String, dynamic>> _suggestions = [];
    bool _isLoading = false;

    final result = await showDialog<Map<String, dynamic>?>(
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
                  final results = await Provider.of<EventCreationProvider>(context, listen: false).fetchLocationSuggestions(value);
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
                            Navigator.pop(context, {
                              'display_name': suggestion['display_name'],
                              'lat': suggestion['lat'],
                              'lon': suggestion['lon'],
                              'address': suggestion['address'], // Contains city, etc.
                            });
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
        selectedLocation = result['display_name'];
        _selectedLatitude = double.tryParse(result['lat']);
        _selectedLongitude = double.tryParse(result['lon']);
        // Try to extract city from the address details
        _selectedCity = result['address']?['city'] ?? result['address']?['town'] ?? result['address']?['village'] ?? "Unknown";
      });
      _showMessage("Selected Manual Location: ${result['display_name']}");
    }
  }

  // Function to navigate to VenueListPage
  Future<void> _navigateToVenueList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VenueListPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedVenueName = result['name'] as String?;
        // Also clear manual venue entry if list is used.
        _manualVenueNameController.clear();
      });
      _showMessage('Selected Venue: ${_selectedVenueName}');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0, //same color when scroll page
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
                onTap: _isPickingImage ? null : _pickImage, // Disable tap while loading
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.pink.shade400, width: 1),
                  ),
                  child: Stack( // Use Stack to overlay the loading indicator
                    alignment: Alignment.center,
                    children: [
                      if (_pickedEventImage != null)
                        Positioned.fill(
                          child: Image.file(_pickedEventImage!, fit: BoxFit.cover),
                        )
                      else
                        Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 50,
                            color: Colors.pink.shade400,
                          ),
                        ),
                      if (_isPickingImage)
                        const CircularProgressIndicator(color: Colors.pink), // Centered loading indicator
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
                    onSelectDateTime: () => _selectStartDateTime(context), // Use new combined function
                    text: 'Select Start Date & Time',
                  ),
                  const SizedBox(height: 20),

                  _buildDateTimeRow(
                    context: context,
                    date: _endDate,
                    time: _endTime,
                    onSelectDateTime: () => _selectEndDateTime(context), // Use new combined function
                    text: 'Select End Date & Time',
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
                  // Option 1: Manual/Current Location (REQUIRED for submission)
                  GestureDetector(
                    onTap: _isFetchingLocation ? null : _handleLocationTap, // Disable tap while loading
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
                                  (selectedLocation?.isNotEmpty ?? false)
                                      ? selectedLocation!
                                      : 'Tap to select manual or current location (Required)',
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
                          if (_isFetchingLocation)
                            const SizedBox(
                              width: 20, // Adjust size as needed
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.pink)),
                            )
                          else
                            Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing for venue options
                  // Toggle for manual venue entry vs. list selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Manually enter Venue Name',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Switch(
                        value: _useManualVenueEntry,
                        onChanged: (bool value) {
                          setState(() {
                            _useManualVenueEntry = value;
                            if (_useManualVenueEntry) {
                              _selectedVenueName = null; // Clear list selection if switching to manual
                            } else {
                              _manualVenueNameController.clear(); // Clear manual entry if switching to list
                            }
                          });
                        },
                        activeColor: Colors.pink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Conditional display based on toggle
                  _useManualVenueEntry
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
                              (_selectedVenueName?.isNotEmpty ?? false)
                                  ? _selectedVenueName!
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
                  maxLines: 5, // allows multi-line input
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

                  // Conditional Widgets for Ticket Price
                  if (_ticketType == 'Paid')
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
                        onPressed: _isCreatingEvent ? null : () async { // Disable button while loading
                          // Validation logic
                          if (_eventNameController.text.isEmpty ||
                              _startDate == null ||
                              _startTime == null ||
                              _endDate == null ||
                              _endTime == null ||
                              _eventDescriptionController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all required fields.')),
                            );
                            return;
                          }

                          // Location validation: manual location is required
                          if (selectedLocation == null || _selectedLatitude == null || _selectedLongitude == null || _selectedCity == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a manual or current event location.')),
                            );
                            return;
                          }

                          final bool isFreeEvent = _ticketType == 'Free';
                          final double? price = isFreeEvent ? 0.0 : double.tryParse(_ticketPrice);

                          if (!isFreeEvent && (price == null || price <= 0)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid ticket price for paid events.')),
                            );
                            return;
                          }

                          // Determine the venue name to send (if any)
                          String? finalVenueName;
                          if (_useManualVenueEntry) {
                            finalVenueName = _manualVenueNameController.text.isEmpty ? null : _manualVenueNameController.text;
                          } else {
                            finalVenueName = _selectedVenueName;
                          }

                          setState(() {
                            _isCreatingEvent = true;
                          });
                          try {
                            // Call the provider's createEvent method using the manual/current location
                            final eventProvider = Provider.of<EventCreationProvider>(context, listen: false);

                            bool success = await eventProvider.createEvent(
                              eventName: _eventNameController.text,
                              startDate: _startDate!,
                              startTime: _startTime!,
                              endDate: _endDate!,
                              endTime: _endTime!,
                              location: selectedLocation!, // Always use the manual/current location
                              city: _selectedCity!,
                              latitude: _selectedLatitude!,
                              longitude: _selectedLongitude!,
                              description: _eventDescriptionController.text,
                              ticketType: _ticketType,
                              ticketPrice: price,
                              pickedImage: _pickedEventImage, // Pass image to provider if you handle upload there
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Event created successfully!')),
                              );
                              Navigator.pop(context); // Go back after successful creation
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to create event. ${eventProvider.errorMessage}')),
                              );
                            }
                          } finally {
                            setState(() {
                              _isCreatingEvent = false;
                            });
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
                        child: _isCreatingEvent
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
  }

  // --- Helper Widget for Date/Time Rows ---
  Widget _buildDateTimeRow({
    required BuildContext context,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onSelectDateTime, // New combined callback
    required String text,
    bool showTimeZone = false,
    String timeZone = '',
  }) {
    String displayText = text;
    if (date != null && time != null) {
      // Format both date and time into a single string
      final now = DateTime.now();
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      displayText = '${DateFormat('dd/MM/yyyy').format(dt)} - ${_formatTime(time)}';
    } else if (date != null) {
      displayText = DateFormat('dd/MM/yyyy').format(date);
    } else if (time != null) {
      displayText = _formatTime(time);
    }


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.pink.shade400, width: 1),
      ),
      child: GestureDetector( // Single GestureDetector for the entire row
        onTap: onSelectDateTime, // Combined tap to trigger both pickers
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.pink), // Single calendar icon
            const SizedBox(width: 8),
            Expanded( // Use Expanded to prevent overflow for long text
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
            Icon(Icons.chevron_right, color: Colors.grey[400]), // Add a chevron for indication
          ],
        ),
      ),
    );
  }
}