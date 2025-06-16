  import 'dart:convert';
  import 'dart:io';
  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:geocoding/geocoding.dart';

  class VenueProvider extends ChangeNotifier {
    TextEditingController venuenameController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController cityController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    File? pickedVenueImage;
    String? selectedLocation;
    double? latitude;
    double? longitude;
    bool isSubmitting = false;
    bool _isLoadingSuggestions = false;

    List<String> availableFacilities = ['Wi-Fi', 'Parking', 'AC', 'Projector', 'Catering'];
    List<String> selectedFacilities = [];

    final ImagePicker _picker = ImagePicker();

    Future<void> pickImage(BuildContext context) async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        pickedVenueImage = File(pickedFile.path);
        notifyListeners();
      }
    }

    Future<void> getCurrentLocation(BuildContext context) async {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          // Show a message to the user that location services are disabled
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location services are disabled. Please enable them.")),
          );
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            // Show a message to the user that permission was denied
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location permissions are denied.")),
            );
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          // Show a message to the user that permission is permanently denied
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are permanently denied. Please enable them in app settings.")),
          );
          return;
        }

        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Construct a full address for selectedLocation
          selectedLocation = "${place.street != null && place.street!.isNotEmpty ? place.street! + ', ' : ''}"
              "${place.locality != null && place.locality!.isNotEmpty ? place.locality! + ', ' : ''}"
              "${place.administrativeArea != null && place.administrativeArea!.isNotEmpty ? place.administrativeArea! + ', ' : ''}"
              "${place.country ?? ''}";

          // Ensure cityController has a value
          cityController.text = place.locality ?? place.subLocality ?? place.administrativeArea ?? "Unknown City";
          latitude = position.latitude;
          longitude = position.longitude;
        }
      } catch (e) {
        debugPrint("🔥 Error getting current location: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error getting current location: $e")),
        );
      }
      notifyListeners();
    }

    Future<List<Map<String, dynamic>>> fetchLocationSuggestions(String query) async {
      // Only make request if query is not empty to avoid unnecessary calls
      if (query.isEmpty) {
        return [];
      }
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        // It's good practice to throw an exception or return an empty list
        // if the API call fails, rather than letting it crash.
        debugPrint("Failed to load suggestions: ${response.statusCode}");
        return [];
      }
    }

    Future<void> showManualLocationPicker(BuildContext context) async {
      TextEditingController _searchController = TextEditingController();
      List<Map<String, dynamic>> _suggestions = [];
      Timer? _debounce;

      final result = await showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            void _onSearchChanged(String value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () async {
                if (value.isNotEmpty) {
                  // Set isLoadingSuggestions to true before fetching
                  _isLoadingSuggestions = true;
                  setState(() {});
                  try {
                    final results = await fetchLocationSuggestions(value);
                    _suggestions = results;
                  } catch (e) {
                    debugPrint("Error fetching location suggestions: $e");
                    _suggestions = [];
                  } finally {
                    // Set isLoadingSuggestions to false after fetching (whether successful or not)
                    _isLoadingSuggestions = false;
                    setState(() {});
                  }
                } else {
                  // Clear suggestions if search query is empty
                  _suggestions = [];
                  setState(() {});
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search or enter location...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _isLoadingSuggestions // Use the local _isLoadingSuggestions
                          ? const Center(child: CircularProgressIndicator())
                          : _suggestions.isEmpty && _searchController.text.isNotEmpty // Only show "Enter manually" if search is active but no suggestions
                          ? Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.edit_location),
                          label: const Text("Enter manually"),
                          onPressed: () {
                            Navigator.pop(context, {
                              "manual": true,
                              "location": _searchController.text,
                            });
                          },
                        ),
                      )
                          : ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            title: Text(suggestion['display_name']),
                            onTap: () {
                              Navigator.pop(context, suggestion);
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

      if (result != null) {
        if (result['manual'] == true) {
          selectedLocation = result['location'];
          // For manually entered location, try to geocode it to get lat/lon
          try {
            List<Location> locations = await locationFromAddress(selectedLocation!);
            if (locations.isNotEmpty) {
              latitude = locations.first.latitude;
              longitude = locations.first.longitude;
              // Attempt to get city from geocoded location, if available
              List<Placemark> placemarks = await placemarkFromCoordinates(latitude!, longitude!);
              if (placemarks.isNotEmpty) {
                cityController.text = placemarks.first.locality ?? placemarks.first.subLocality ?? placemarks.first.administrativeArea ?? '';
              } else {
                cityController.text = "Custom City"; // Fallback if no city found
              }
            } else {
              latitude = null;
              longitude = null;
              cityController.text = "Custom City"; // Fallback if no location found
            }
          } catch (e) {
            debugPrint("Error geocoding manual location: $e");
            latitude = null;
            longitude = null;
            cityController.text = "Custom City"; // Fallback on error
          }
        } else {
          selectedLocation = result['display_name'];
          latitude = double.tryParse(result['lat'].toString());
          longitude = double.tryParse(result['lon'].toString());
          final address = result['address'];
          cityController.text = address?['city'] ?? address?['town'] ?? address?['village'] ?? address?['county'] ?? '';
        }
        notifyListeners();
      }
    }

    Future<void> addVenue(BuildContext context) async {
      isSubmitting = true;
      notifyListeners();

      try {
        // Basic validation: Check if essential fields are not empty
        if (venuenameController.text.isEmpty ||
            addressController.text.isEmpty ||
            cityController.text.isEmpty ||
            descriptionController.text.isEmpty ||
            selectedLocation == null ||
            latitude == null ||
            longitude == null ||
            pickedVenueImage == null ||
            selectedFacilities.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill in all required fields and select an image/location/facilities.")),
          );
          isSubmitting = false;
          notifyListeners();
          return;
        }


        final prefs = await SharedPreferences.getInstance();
        final backendUserId = prefs.getString("backendUserId");

        // Check if backendUserId is available
        if (backendUserId == null || backendUserId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not logged in or backend user ID is missing.")),
          );
          isSubmitting = false;
          notifyListeners();
          return;
        }

        final uri = Uri.parse('http://srv861272.hstgr.cloud:8000/api/post/venue');
        final request = http.MultipartRequest('POST', uri);

        request.fields['user'] = backendUserId;
        // ✅ Use actual data from controllers and selected states
        request.fields['title'] = venuenameController.text;
        request.fields['content'] = descriptionController.text;
        request.fields['location'] = addressController.text; // Assuming addressController holds the detailed location/address
        request.fields['city'] = cityController.text;
        request.fields['latitude'] = latitude!.toString();
        request.fields['longitude'] = longitude!.toString();
        request.fields['description'] = descriptionController.text; // ✅ This line must be exactly like this
        request.fields['facilities'] = selectedFacilities.join(', '); // Join selected facilities with a comma and space

        if (pickedVenueImage != null) {
          final image = await http.MultipartFile.fromPath(
            'media', // This must match the backend's expected field name for the file
            pickedVenueImage!.path,
          );
          request.files.add(image);
        } else {
          // Handle case where image is not picked, if your backend requires it.
          // For now, it will be handled by the validation above.
          debugPrint("No venue image picked.");
        }


        debugPrint("📤 Sending fields: ${request.fields}");
        debugPrint("📸 File count: ${request.files.length}");

        final streamedResponse = await request.send();
        final respStr = await streamedResponse.stream.bytesToString();

        debugPrint("📥 Status Code: ${streamedResponse.statusCode}");
        debugPrint("📥 Raw Response Body: $respStr");

        // Ensure the response string is not empty before decoding
        if (respStr.isNotEmpty) {
          final decoded = json.decode(respStr);
          debugPrint("📦 Decoded Response JSON: $decoded");

          if (streamedResponse.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Venue added successfully!")),
            );
            // Optionally, clear fields after successful submission
            venuenameController.clear();
            addressController.clear();
            cityController.clear();
            descriptionController.clear();
            pickedVenueImage = null;
            selectedLocation = null;
            latitude = null;
            longitude = null;
            selectedFacilities.clear();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ Error: ${decoded['message'] ?? 'Unknown error'} - Status Code: ${streamedResponse.statusCode}")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Error: Empty response from server. Status Code: ${streamedResponse.statusCode}")),
          );
        }
      } catch (e) {
        debugPrint("🔥 Exception during venue submission: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Submission error: $e")),
        );
      } finally {
        isSubmitting = false;
        notifyListeners();
      }
    }

    @override
    void dispose() {
      venuenameController.dispose();
      addressController.dispose();
      cityController.dispose();
      descriptionController.dispose();
      super.dispose();
    }
  }