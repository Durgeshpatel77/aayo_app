// screens/AddVenueScreen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../widgets/TextField _editprofiile.dart'; // Import image_picker

class AddVenueScreen extends StatefulWidget {
  const AddVenueScreen({super.key});

  @override
  State<AddVenueScreen> createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends State<AddVenueScreen> {
  TextEditingController venuename=TextEditingController();
  TextEditingController adrees=TextEditingController();
  TextEditingController postalcode=TextEditingController();
  TextEditingController city=TextEditingController();

  // State variable to store the picked image file for the venue
  File? _pickedVenueImage;
  String? selectedLocation;


  // Method to handle picking an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery); // Or ImageSource.camera

    if (pickedFile != null) {
      setState(() {
        _pickedVenueImage = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue image picked successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selection cancelled.')),
      );
    }
  }


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
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Dark background color
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Add Venue'),
        backgroundColor:  Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Removes default back button or menu
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new_sharp)),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NEW: Image Picker Section at the top of the Column ---
            GestureDetector(
              onTap: _pickImage, // Call _pickImage when the container is tapped
              child: Container(
                width: double.infinity, // Take full width
                height: 200, // Fixed height for the image area
                decoration: BoxDecoration(
                  color:
                      Colors.white, // Darker background for the image area
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.pink[400]!, width: 1), // Subtle border
                  image: _pickedVenueImage != null
                      ? DecorationImage(
                          image: FileImage(_pickedVenueImage!),
                          fit: BoxFit.cover,
                        )
                      : null, // No image if _pickedVenueImage is null
                ),
                alignment: Alignment.center,
                child: _pickedVenueImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo, // Icon for adding a photo
                            color: Colors.pink[400],
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap to Add Venue Image',
                            style: TextStyle(
                              color: Colors.pink[400],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : null, // No child if image is picked
              ),
            ),
            const SizedBox(height: 30), // Space after the image picker

            // Venue Name Field
            TextfieldEditprofiile(
              controller: venuename,
              hintText: 'Enter venue name',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 20),
            // Address Field
            TextfieldEditprofiile(
              controller: adrees,
              hintText: 'Enter Address',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 20),
            // Postal Code Field
            GestureDetector(
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
            const SizedBox(height: 20),
            // City Field
            TextfieldEditprofiile(
              controller: city,
              hintText: 'Enter city',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 40),
            // You might want to add a "Save Venue" button here
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement logic to save venue details and _pickedVenueImage
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Venue details saved!')),
                        );
                        Navigator.pop(context); // Go back after saving
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Venue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
