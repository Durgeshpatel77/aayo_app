// lib/venue_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VenueProvider extends ChangeNotifier {
  /// ---------------- Text‑field controllers ----------------
  final venuenameController = TextEditingController();
  final addressController  = TextEditingController();
  final cityController     = TextEditingController();
  final descriptionController = TextEditingController();

  /// ---------------- Image, location & form helpers ----------------
  final ImagePicker _picker = ImagePicker();
  File? pickedVenueImage;

  String?  selectedLocation;
  double?  latitude;
  double?  longitude;

  /// ---------------- Facility selection ----------------
  final List<String> availableFacilities = [
    'Wi‑Fi', 'Parking', 'AC', 'Projector', 'Catering'
  ];
  final List<String> selectedFacilities  = [];

  /// ---------------- Venue list state ----------------
  List<Map<String, dynamic>> _venues = [];
  bool _isLoadingVenues   = false;
  String? _venueFetchError;

  List<Map<String, dynamic>> get venues => _venues;
  bool get isLoadingVenues => _isLoadingVenues;
  String? get venueFetchError => _venueFetchError;

  /// ---------------- UI helpers ----------------
  bool isSubmitting            = false;
  bool _isLoadingSuggestions   = false;

  /* ============================================================
   *                       Image Picker
   * ============================================================
   */
  Future<void> pickImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedVenueImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  /* ============================================================
   *                     Current‑location logic
   * ============================================================
   */
  Future<void> getCurrentLocation(BuildContext context) async {
    try {
      // 1. Service check
      if (!await Geolocator.isLocationServiceEnabled()) {
        _snack(context, 'Location services are disabled. Please enable them.');
        return;
      }

      // 2. Permission check
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _snack(context, 'Location permission denied.');
        return;
      }

      // 3. Get coordinates + placemark
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemark = (await placemarkFromCoordinates(
        pos.latitude, pos.longitude,
      ))
          .first;

      selectedLocation = [
        if (placemark.street?.isNotEmpty ?? false) placemark.street,
        placemark.locality,
        placemark.administrativeArea,
        placemark.country,
      ].where((e) => e != null && e!.isNotEmpty).join(', ');

      cityController.text =
          placemark.locality ?? placemark.subLocality ?? placemark.administrativeArea ?? 'Unknown city';

      latitude  = pos.latitude;
      longitude = pos.longitude;
      notifyListeners();
    } catch (e) {
      _snack(context, 'Error getting current location: $e');
    }
  }

  /* ============================================================
   *           Location suggestions (OpenStreetMap Nominatim)
   * ============================================================
   */
  Future<List<Map<String, dynamic>>> _fetchLocationSuggestions(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    }
    debugPrint('Failed to load suggestions: ${res.statusCode}');
    return [];
  }

  Future<void> showManualLocationPicker(BuildContext context) async {
    final searchCtrl    = TextEditingController();
    List<Map<String, dynamic>> suggestions = [];
    Timer? debounce;

    final picked = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: true,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: Column(
              children: [
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search or enter location...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) {
                    if (debounce?.isActive ?? false) debounce!.cancel();
                    debounce = Timer(const Duration(milliseconds: 500), () async {
                      _isLoadingSuggestions = true;
                      setState(() {});
                      suggestions = await _fetchLocationSuggestions(val);
                      _isLoadingSuggestions = false;
                      setState(() {});
                    });
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoadingSuggestions
                      ? const Center(child: CircularProgressIndicator())
                      : suggestions.isEmpty && searchCtrl.text.isNotEmpty
                      ? Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.edit_location),
                      label: const Text('Enter manually'),
                      onPressed: () => Navigator.pop(context, {
                        'manual': true,
                        'location': searchCtrl.text,
                      }),
                    ),
                  )
                      : ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (_, i) => ListTile(
                      title: Text(suggestions[i]['display_name']),
                      onTap: () => Navigator.pop(context, suggestions[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (picked == null) return;

    // ---- Manual entry ----
    if (picked['manual'] == true) {
      selectedLocation = picked['location'];
      try {
        final locs = await locationFromAddress(selectedLocation!);
        if (locs.isNotEmpty) {
          latitude  = locs.first.latitude;
          longitude = locs.first.longitude;
          final placemarks = await placemarkFromCoordinates(latitude!, longitude!);
          cityController.text = placemarks.isNotEmpty
              ? placemarks.first.locality ?? placemarks.first.administrativeArea ?? ''
              : 'Custom City';
        }
      } catch (_) {
        cityController.text = 'Custom City';
      }
    }
    // ---- Suggestion pick ----
    else {
      selectedLocation = picked['display_name'];
      latitude  = double.tryParse(picked['lat'].toString());
      longitude = double.tryParse(picked['lon'].toString());
      final addr = picked['address'];
      cityController.text =
          addr?['city'] ?? addr?['town'] ?? addr?['village'] ?? addr?['county'] ?? '';
    }
    notifyListeners();
  }

  /* ============================================================
   *                        Fetch venues
   * ============================================================
   */
  Future<void> fetchVenues() async {
    _isLoadingVenues = true;
    _venueFetchError = null;
    notifyListeners();

    final url = Uri.parse('http://srv861272.hstgr.cloud:8000/api/post?type=venue');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          _venues = List<Map<String, dynamic>>.from(data['data']['posts']);
        } else {
          _venueFetchError = 'Failed: ${data['message'] ?? 'Unknown error'}';
        }
      } else {
        _venueFetchError = 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _venueFetchError = 'Error: $e';
    } finally {
      _isLoadingVenues = false;
      notifyListeners();
    }
  }

  /* ============================================================
   *                      Add (POST) venue
   * ============================================================
   */
  Future<void> addVenue(BuildContext context) async {
    // --- Validation --------------------------------------------------------
    if (venuenameController.text.isEmpty ||
        addressController.text.isEmpty   ||
        cityController.text.isEmpty      ||
        descriptionController.text.isEmpty ||
        selectedLocation == null         ||
        latitude  == null                ||
        longitude == null                ||
        pickedVenueImage == null         ||
        selectedFacilities.isEmpty) {
      _snack(context, 'Please fill all fields, pick image, location & facilities.');
      return;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId');
      if (userId == null) {
        _snack(context, 'User not logged in.');
        return;
      }

      final req = http.MultipartRequest(
        'POST',
        Uri.parse('http://srv861272.hstgr.cloud:8000/api/post/venue'),
      )
        ..fields.addAll({
          'user'        : userId,
          'title'       : venuenameController.text,
          'content'     : descriptionController.text,
          'location'    : addressController.text,
          'city'        : cityController.text,
          'latitude'    : latitude.toString(),
          'longitude'   : longitude.toString(),
          'description' : descriptionController.text,
          'facilities'  : selectedFacilities.join(', '),
        })
        ..files.add(await http.MultipartFile.fromPath('media', pickedVenueImage!.path));

      final res = await req.send();
      final body = await res.stream.bytesToString();
      final decoded = body.isNotEmpty ? json.decode(body) : {};

      if (res.statusCode == 201) {
        _snack(context, 'Venue added successfully ✅');
        clearForm();
        // Optionally refresh venue list
        await fetchVenues();
      } else {
        _snack(context, 'Error ${res.statusCode}: ${decoded['message'] ?? 'Unknown'}');
      }
    } catch (e) {
      _snack(context, 'Submission error: $e');
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  /* ============================================================
   *                        Helpers
   * ============================================================
   */
  void clearForm() {
    venuenameController.clear();
    addressController.clear();
    cityController.clear();
    descriptionController.clear();
    pickedVenueImage = null;
    selectedLocation = null;
    latitude  = null;
    longitude = null;
    selectedFacilities.clear();
    notifyListeners();
  }

  void _snack(BuildContext ctx, String msg) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    venuenameController.dispose();
    addressController.dispose();
    cityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
