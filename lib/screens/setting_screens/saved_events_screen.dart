import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/event_model.dart';
import '../event_detail_screens/events_details.dart';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({super.key});

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  List<Event> savedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadSavedEvents();
  }

  Future<void> _loadSavedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('savedEvents') ?? [];

    final events = savedList.map((e) {
      try {
        return Event.fromJson(jsonDecode(e));
      } catch (_) {
        return null;
      }
    }).whereType<Event>().toList();

    setState(() {
      savedEvents = events;
    });
  }

  bool _isSaved(Event event) {
    return savedEvents.any((e) => e.id == event.id);
  }

  Future<void> _toggleSave(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('savedEvents') ?? [];

    final eventJson = jsonEncode(event.toJson());

    final isAlreadySaved = _isSaved(event);

    if (isAlreadySaved) {
      // Remove from saved
      savedList.removeWhere((e) => Event.fromJson(jsonDecode(e)).id == event.id);
    } else {
      if (savedList.length >= 4) {
        // Show alert if max limit reached
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Limit Reached'),
              content: const Text('You can only save up to 4 events. Please remove one to add more.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
      // Add to saved
      savedList.add(eventJson);
    }

    await prefs.setStringList('savedEvents', savedList);
    _loadSavedEvents();
  }

  String _formatTime(DateTime time) {
    return DateFormat('dd MMM, hh:mm a').format(time);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Events'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_sharp),
        ),
      ),
      backgroundColor: Colors.white,
      body: savedEvents.isEmpty
          ? const Center(child: Text('Your saved events will be displayed here.'))
          : ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: savedEvents.length,
        itemBuilder: (context, index) {
          final event = savedEvents[index];
          return _buildSavedEventCard(event, screenWidth, screenHeight);
        },
      ),
    );
  }

  Widget _buildSavedEventCard(Event event, double screenWidth, double screenHeight) {
    final imageUrl = event.image.isNotEmpty
        ? event.image
        : (event.media.isNotEmpty ? event.media.first : '');

    final formattedDate = _formatTime(event.startTime);
    final price = event.isFree ? "Free" : "₹${event.price.toStringAsFixed(0)}";
    final city = event.location;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.025),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey, width: 0.5),
          color: Colors.white,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: screenWidth * 0.33,
                height: screenWidth * 0.44,
                fit: BoxFit.cover,
              )
                  : Container(
                width: screenWidth * 0.33,
                height: screenWidth * 0.38,
                color: Colors.grey.shade100,
                child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.007),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.pink),
                        SizedBox(width: screenWidth * 0.015),
                        Flexible(
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.006),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.orange),
                        SizedBox(width: screenWidth * 0.015),
                        Flexible(
                          child: Text(
                            city,
                            style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.006,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            price,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.pink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            _isSaved(event) ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final savedList = prefs.getStringList('savedEvents') ?? [];

                            if (_isSaved(event)) {
                              // Remove the event
                              savedList.removeWhere((e) => Event.fromJson(jsonDecode(e)).id == event.id);
                              await prefs.setStringList('savedEvents', savedList);
                              _loadSavedEvents();

                              // Show snackbar with pink undo
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Event removed from saved'),
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    textColor: Colors.pink, // 🔴 Make Undo pink
                                    onPressed: () async {
                                      final updatedList = prefs.getStringList('savedEvents') ?? [];
                                      updatedList.add(jsonEncode(event.toJson()));
                                      await prefs.setStringList('savedEvents', updatedList);
                                      _loadSavedEvents();
                                    },
                                  ),
                                ),
                              );
                            } else {
                              // Enforce 4-event max
                              if (savedList.length >= 4) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You can only save up to 4 events.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              // Save event
                              savedList.add(jsonEncode(event.toJson()));
                              await prefs.setStringList('savedEvents', savedList);
                              _loadSavedEvents();
                            }
                          },
                        )

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
