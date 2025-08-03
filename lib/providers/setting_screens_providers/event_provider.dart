// lib/providers/setting_screens_providers/event_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:geolocator/geolocator.dart'; // Import geolocator

import 'package:path/path.dart' as path;

import '../../models/create_event_model.dart';

class EventCreationProvider with ChangeNotifier {
  final List<EventModel> _allEvents = [];
  Map<String, dynamic>? _lastApiResponse;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isFetchingEvents = false;
  final List<EventModel> _createdEvents = [];
  final List<EventModel> _joinedEvents = [];
  List<EventModel> _pastEvents = [];
  List<EventModel> get pastEvents => _pastEvents;

  List<EventModel> get createdEvents => _createdEvents;
  List<EventModel> get joinedEvents => _joinedEvents;

  // New state variables for CreateEventScreen logic
  File? _pickedEventImage;
  String? _selectedLocation;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedCity;
  String? _selectedVenueName;
  bool _useManualVenueEntry = false;

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  String _ticketType = 'Free';
  String _ticketPrice = '';

  bool _isPickingImage = false;
  bool _isFetchingCurrentLocation = false;
  // End new state variables

  List<EventModel> get allEvents => _allEvents;
  Map<String, dynamic>? get lastApiResponse => _lastApiResponse;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isFetchingEvents => _isFetchingEvents;

  // New Getters for UI
  File? get pickedEventImage => _pickedEventImage;
  String? get selectedLocation => _selectedLocation;
  double? get selectedLatitude => _selectedLatitude;
  double? get selectedLongitude => _selectedLongitude;
  String? get selectedCity => _selectedCity;
  String? get selectedVenueName => _selectedVenueName;
  bool get useManualVenueEntry => _useManualVenueEntry;
  DateTime? get startDate => _startDate;
  TimeOfDay? get startTime => _startTime;
  DateTime? get endDate => _endDate;
  TimeOfDay? get endTime => _endTime;
  String get ticketType => _ticketType;
  String get ticketPrice => _ticketPrice;
  bool get isPickingImage => _isPickingImage;
  bool get isFetchingCurrentLocation => _isFetchingCurrentLocation;
  // End New Getters
  String _customQuestion = ''; // 🔴 Add this

  String get customQuestion => _customQuestion; // Getter

  Map<String, dynamic>? _fetchedEventData;
  bool _isFetchingSingleEvent = false;
  String? _fetchEventError;

  Map<String, dynamic>? get fetchedEventData => _fetchedEventData;
  bool get isFetchingSingleEvent => _isFetchingSingleEvent;
  String? get fetchEventError => _fetchEventError;

  Future<void> fetchSingleEventById(String eventId) async {
    _isFetchingSingleEvent = true;
    _fetchEventError = null;
    notifyListeners();

    final url = 'http://82.29.167.118:8000/api/post/event'; // ✅ POST for both create & fetch
    print('🔵 Fetching event via POST: $url');

    final requestBody = {
      "type": "event",
      "user": "6885d763501c5817dcefd010",  // Your user ID
      "postId": eventId,  // Assume this is how server identifies which post to fetch
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('📤 Sent Body: ${json.encode(requestBody)}');
      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _fetchedEventData = data['data'];
        print('✅ Event Data Fetched: $_fetchedEventData');
      } else {
        _fetchEventError = 'Failed to load event. Code: ${response.statusCode}';
        print('❌ Error: $_fetchEventError');
      }
    } catch (e) {
      _fetchEventError = 'Exception: $e';
      print('❌ Exception: $e');
    } finally {
      _isFetchingSingleEvent = false;
      notifyListeners();
    }
  }
  // Future<bool> updateEvent(String eventId, Map<String, dynamic> updatedData) async {
  //   final url = 'http://82.29.167.118:8000/api/post/event/$eventId';
  //   try {
  //     final response = await http.put(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(updatedData),
  //     );
  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       print('Update failed: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Update error: $e');
  //     return false;
  //   }
  // }


  void setCustomQuestion(String question) {
    _customQuestion = question.trim();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetchingEvents(bool value) {
    _isFetchingEvents = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // New Setters for UI to update state
  void setPickedEventImage(File? image) {
    _pickedEventImage = image;
    notifyListeners();
  }

  void setSelectedLocation(
      String? location, double? lat, double? lon, String? city) {
    _selectedLocation = location;
    _selectedLatitude = lat;
    _selectedLongitude = lon;
    _selectedCity = city;
    notifyListeners();
  }

  void setSelectedVenueName(String? venueName) {
    _selectedVenueName = venueName;
    notifyListeners();
  }

  void setUseManualVenueEntry(bool value) {
    _useManualVenueEntry = value;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay? time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    notifyListeners();
  }

  void setEndTime(TimeOfDay? time) {
    _endTime = time;
    notifyListeners();
  }

  void setTicketType(String type) {
    _ticketType = type;
    notifyListeners();
  }

  void setTicketPrice(String price) {
    _ticketPrice = price;
    notifyListeners();
  }

  void _setIsPickingImage(bool value) {
    _isPickingImage = value;
    notifyListeners();
  }

  void _setIsFetchingCurrentLocation(bool value) {
    _isFetchingCurrentLocation = value;
    notifyListeners();
  }
  // End New Setters

  // --- Image Picking Function ---

  Future<String?> pickImage() async {
    _setIsPickingImage(true);
    _clearError();
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return 'Image selection cancelled.';

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 70,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            hideBottomControls: true,
            showCropGrid: true,
            cropGridStrokeWidth: 2,
            cropFrameStrokeWidth: 2,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
          ),
        ],
      );

      if (croppedFile == null) return 'Image cropping cancelled.';

      // 🧾 Original size
      final originalSize = File(croppedFile.path).lengthSync();
      debugPrint(
          '📸 Original image size: ${(originalSize / 1024).toStringAsFixed(2)} KB');

      // 🗜️ Compress image
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'event_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        targetPath,
        quality: 50,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (compressedImage == null) return 'Image compression failed.';

      final compressedSize = File(compressedImage.path).lengthSync();
      debugPrint(
          '🗜️ Compressed image size: ${(compressedSize / 1024).toStringAsFixed(2)} KB');

      // ✅ Save to provider
      setPickedEventImage(File(compressedImage.path));
      return 'Event image picked, cropped, and compressed.';
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      return 'Failed to pick or compress image.';
    } finally {
      _setIsPickingImage(false);
    }
  }

  // --- Current Location Fetching ---
  Future<String?> getCurrentLocation() async {
    _setIsFetchingCurrentLocation(true);
    _clearError();
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled.';
        return 'Location services are disabled.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied.';
          return 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied.';
        return 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];
      String address =
          '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

      setSelectedLocation(
          address, position.latitude, position.longitude, place.locality);
      return 'Selected Current Location: $address';
    } catch (e) {
      _errorMessage = 'Failed to get current location: $e';
      return 'Failed to get current location.';
    } finally {
      _setIsFetchingCurrentLocation(false);
    }
  }

  Future<bool> createEvent({
    required String eventName,
    required String description,
    required String location,
    required String venueName,
    required String venueAddress,
    required BuildContext context,
    required List<String> tags,
    required List<String> customQuestions,
    bool isOnlineEvent = false, // 🆕
  }) async {
    _clearError();
    _setLoading(true);

    // ✅ Validate common required fields
    if (eventName.trim().isEmpty ||
        _startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null ||
        description.trim().isEmpty) {
      _errorMessage = "Please fill all required fields.";
      _setLoading(false);
      return false;
    }

    // ✅ Extra validation for OFFLINE events only
    if (!isOnlineEvent) {
      if (location.trim().isEmpty ||
          venueName.trim().isEmpty ||
          venueAddress.trim().isEmpty) {
        _errorMessage = "Please fill location, venue name, and address for offline events.";
        _setLoading(false);
        return false;
      }
    }

    // ✅ Determine ticket type & price
    final bool isFreeEvent = (_ticketType == 'Free');
    final double priceToSend =
    isFreeEvent ? 0.0 : double.tryParse(_ticketPrice) ?? 0.0;

    try {
      final prefs = await SharedPreferences.getInstance();
      final backendUserId = prefs.getString("backendUserId");

      if (backendUserId == null || backendUserId.isEmpty) {
        _errorMessage = "User not logged in.";
        _setLoading(false);
        return false;
      }

      // ✅ Build start & end datetime
      final DateTime startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final DateTime endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final uri = Uri.parse('http://82.29.167.118:8000/api/post/event');
      final request = http.MultipartRequest('POST', uri);

      // 🟢 Always-required fields for both online & offline events
      request.fields['type'] = "event";
      request.fields['user'] = backendUserId;
      request.fields['title'] = eventName;
      request.fields['content'] = description;
      request.fields['startTime'] = startDateTime.toIso8601String();
      request.fields['endTime'] = endDateTime.toIso8601String();
      request.fields['isFree'] = isFreeEvent.toString();
      request.fields['price'] = priceToSend.toString();
      request.fields['tags'] = tags.isNotEmpty ? tags.join(',') : '';
      request.fields['description'] = description;

      // 🟡 Online/Offline-specific location fields
      request.fields['isOnlineEvent'] = isOnlineEvent.toString();
      if (isOnlineEvent) {
        request.fields['venueName'] = 'Online Event';
        request.fields['venueAddress'] = venueAddress; // Online link
        request.fields['location'] = 'Online';
        request.fields['city'] = 'Online';
        request.fields['latitude'] = "0.0";
        request.fields['longitude'] = "0.0";
      } else {
        request.fields['venueName'] = venueName;
        request.fields['venueAddress'] = venueAddress;
        request.fields['location'] = location;
        request.fields['city'] = location; // Or actual city if available
        request.fields['latitude'] = _selectedLatitude?.toString() ?? "0.0";
        request.fields['longitude'] = _selectedLongitude?.toString() ?? "0.0";
      }

      debugPrint("🟢 Tags: ${request.fields['tags']}");

      // ✅ Add customQuestions if any
      if (customQuestions.isNotEmpty) {
        request.fields['customQuestions'] = jsonEncode(customQuestions);
        debugPrint("✅ customQuestions JSON: ${request.fields['customQuestions']}");
      }

      // ✅ Add event image if selected
      if (_pickedEventImage != null) {
        final image = await http.MultipartFile.fromPath('media', _pickedEventImage!.path);
        request.files.add(image);
      } else {
        debugPrint("No event image picked.");
      }

      debugPrint("📤 Sending request: ${request.fields}");
      final streamedResponse = await request.send();
      final respStr = await streamedResponse.stream.bytesToString();

      debugPrint("📥 Status Code: ${streamedResponse.statusCode}");
      debugPrint("📥 Response Body: $respStr");

      if (respStr.isNotEmpty) {
        final decoded = json.decode(respStr);
        debugPrint("📥 Decoded Response: $decoded");

        if (decoded['success'] == true) {
          clearAllEventData(); // ✅ Reset form

          if (decoded['data']?['eventDetails']?['customQuestions'] != null) {
            debugPrint("✅ Server Stored Custom Questions: ${decoded['data']['eventDetails']['customQuestions']}");
          } else {
            debugPrint("⚠️ Server did not return customQuestions.");
          }

          return true; // ✅ Success
        } else {
          _errorMessage = 'Server error: ${decoded['message'] ?? 'Unknown error'}';
          return false;
        }
      } else {
        _errorMessage = 'Empty response from server.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Exception during event creation: $e';
      debugPrint("❌ Exception: $_errorMessage");
      return false;
    } finally {
      _setLoading(false);
    }
  }
  Future<void> fetchUserPostsFromPrefs( {String? type}) async {
    _clearError();
    _setFetchingEvents(true);
    _createdEvents.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("backendUserId");

      if (userId == null || userId.isEmpty) {
        _errorMessage = "User ID not found in SharedPreferences.";
        return;
      }

      String url = 'http://82.29.167.118:8000/api/post?user=$userId';
      if (type != null && type.isNotEmpty) {
        url += '&type=$type';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint("🛰 Status Code: ${response.statusCode}");
      debugPrint("📦 Raw Body: ${response.body}");

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        if (decoded['success'] == true &&
            decoded['data'] != null &&
            decoded['data']['posts'] != null) {
          final List<dynamic> postsJson = decoded['data']['posts'];

          for (var i = 0; i < postsJson.length; i++) {
            debugPrint("🔍 Post[$i]: ${jsonEncode(postsJson[i])}");
          }
          _createdEvents.addAll(
            postsJson.map((json) => EventModel.fromJson(json)).toList(),
          );
          _errorMessage = null;
        } else {
          _errorMessage = "Failed to parse posts: ${decoded['message']}";
        }
      } else if (response.statusCode == 404 &&
          decoded['message'] == 'Posts not found') {
        _joinedEvents.clear();
        _errorMessage = null;
      } else {
        _errorMessage = 'Error ${response.statusCode}: ${decoded['message']}';
      }
    } catch (e, st) {
      _errorMessage = '❌ Network error during user post fetch: $e';
      debugPrint(_errorMessage!);
      debugPrint('📍 Stack trace:\n$st');
    } finally {
      _setFetchingEvents(false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocationSuggestions(
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
      _errorMessage =
      'Failed to fetch location suggestions: ${response.statusCode}';
      print('Failed to fetch location suggestions: ${response.statusCode}');
      return [];
    }
  }

  // Helper to format TimeOfDay (kept here for consistency, or can be a utility)
  String formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt); // e.g., 11:00 PM
  }

  // Method to handle combined date and time selection
  Future<void> selectStartDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
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
    if (pickedDate != null) {
      setStartDate(pickedDate);
      // Only proceed to time if date was picked
      final TimeOfDay? pickedTime = await showTimePicker(
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
      if (pickedTime != null && pickedTime != _startTime) {
        setStartTime(pickedTime);
      }
    }
  }

  Future<void> selectEndDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
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

    if (pickedDate != null) {
      if (_startDate != null && pickedDate.isBefore(_startDate!)) {
        // This message should be shown by the UI, but we can return a flag/message
        _errorMessage = 'End date can’t be before start date';
        notifyListeners(); // Notify listeners about the error
        return;
      }

      setEndDate(pickedDate);
      final TimeOfDay? pickedTime = await showTimePicker(
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
      if (pickedTime != null && pickedTime != _endTime) {
        setEndTime(pickedTime);
      }
    }
  }

  Future<void> fetchJoinedEventsFromPrefs() async {
    _clearError();
    _setFetchingEvents(true);
    _allEvents.clear();
    _joinedEvents.clear(); // ✅ Clear the list to avoid duplicates
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      final joinedEventIds = prefs.getStringList('joinedEvents') ?? [];

      for (final id in joinedEventIds) {
        final response =
        await http.get(Uri.parse('http://82.29.167.118:8000/api/post/$id'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          if (data != null) {
            _joinedEvents.add(EventModel.fromJson(data));
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch joined events: $e';
    } finally {
      _setFetchingEvents(false);
    }

    notifyListeners();
  }

  Future<void> fetchPastEventsFromPrefs() async {
    _clearError();
    _setFetchingEvents(true);
    _pastEvents.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("backendUserId");

      if (userId == null || userId.isEmpty) return;

      final url = 'http://82.29.167.118:8000/api/post?user=$userId&type=event';
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final posts = decoded['data']['posts'] as List;

        final now = DateTime.now();
        _pastEvents.addAll(
          posts
              .map((json) => EventModel.fromJson(json))
              .where((event) =>
          event.type == 'event' &&
              event.eventDetails != null &&
              event.eventDetails!.endTime.isBefore(now))
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('❌ fetchPastEvents error: $e');
    } finally {
      _setFetchingEvents(false);
    }
  }

  Future<void> sendEventNotificationToFollowers({
    required BuildContext context,
    required String eventImageUrl,
    required String eventTitle,
    required String senderName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backendUserId = prefs.getString('backendUserId');
      final userMobile = prefs.getString('backendUserMobile') ?? '';
      final userAvatar = prefs.getString('backendUserProfile') ?? '';

      if (backendUserId == null || backendUserId.isEmpty) {
        debugPrint('❌ backendUserId missing — cannot send event notification');
        return;
      }

      // 🔁 Step 1: Get all followers
      final followersUrl =
      Uri.parse('http://82.29.167.118:8000/api/user/$backendUserId');
      final followersResponse = await http.get(followersUrl);

      if (followersResponse.statusCode != 200) {
        debugPrint('❌ Failed to fetch followers for notification');
        debugPrint('📥 Status: ${followersResponse.statusCode}');
        debugPrint('📥 Body: ${followersResponse.body}');
        return;
      }

      final followersData = jsonDecode(followersResponse.body);
      final followersList = followersData['data']['followers'] as List;

      // 🔁 Loop through each follower
      for (var follower in followersList) {
        final followerId = follower['_id'];

        // 🔎 Step 2: Get follower details to get FCM token
        final detailRes = await http.get(
          Uri.parse('http://82.29.167.118:8000/api/user/$followerId'),
        );

        if (detailRes.statusCode == 200) {
          final followerDetails = jsonDecode(detailRes.body);
          final fcmToken = followerDetails['data']['fcmToken'];

          if (fcmToken != null && fcmToken.toString().isNotEmpty) {
            // 📤 Step 3: Send notification
            final notificationUrl =
            Uri.parse('http://82.29.167.118:8000/api/send-notification');

            final notificationBody = {
              'fcmToken': fcmToken,
              "title": "$senderName is hosting a new event!",
              'body': eventTitle,
              'imageUrl': eventImageUrl,
              'data': {
                'type': 'event',
                'userId': backendUserId,
                'userName': senderName,
                'userMobile': userMobile,
                'userAvatar': userAvatar,
                'eventImage': eventImageUrl,
              },
            };

            final notificationRes = await http.post(
              notificationUrl,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(notificationBody),
            );

            debugPrint('✅ Notification sent to follower $followerId');
            debugPrint('📥 Notification response: ${notificationRes.body}');
          } else {
            debugPrint('⚠️ No FCM token for follower $followerId');
          }
        } else {
          debugPrint('❌ Failed to fetch details for follower $followerId');
          debugPrint('📥 Status: ${detailRes.statusCode}');
          debugPrint('📥 Body: ${detailRes.body}');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('📣 Event notifications sent to followers!')),
        );
      }
    } catch (e, stack) {
      debugPrint('❌ Exception while sending event notifications: $e');
      debugPrint('🧱 Stacktrace: $stack');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }
  void clearAllEventData() {
    _pickedEventImage = null;
    _startDate = null;
    _startTime = null;
    _endDate = null;
    _endTime = null;
    _ticketType = 'Free';
    _ticketPrice = '';
    _selectedVenueName = null;
    _useManualVenueEntry = false;
    _selectedLocation = null;
    _selectedLatitude = null;
    _selectedLongitude = null;
    _selectedCity = null;
    _customQuestion = ''; // ✅
    notifyListeners();
  }

}