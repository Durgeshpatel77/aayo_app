// lib/providers/home_provider.dart
import 'package:flutter/material.dart';
import 'package:aayo/models/event_model.dart';

class homeProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  List<Event> _userPostedEvents = [];

  final List<Event> _randomEvents = [
    Event(
        id: '1',
        name: "Startup Meetup: Innovate & Connect",
        imageUrl:
        'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        caption: 'A great networking event for startups.',
        location: 'Ahmedabad',
        category: 'Tech',
        organizer: 'Innovate Hub',
        price: 25.00,
        date: DateTime(2025, 6, 15),
        time: const TimeOfDay(hour: 10, minute: 0),
        eventDateTime: DateTime(2025, 6, 15, 10, 0)),
    Event(
        id: '2',
        name: "Groovy Music Fest 2024: Summer Beats",
        imageUrl:
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        caption: 'Experience the best summer beats!',
        location: 'Goa',
        category: 'Music',
        organizer: 'Beat Masters',
        price: 150.00,
        date: DateTime(2025, 7, 20),
        time: const TimeOfDay(hour: 18, minute: 0),
        eventDateTime: DateTime(2025, 7, 20, 18, 0)),
    Event(
        id: '3',
        name: "Future of AI: A Deep Dive Tech Talk",
        imageUrl:
        'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        caption: 'Explore the latest in Artificial Intelligence.',
        location: 'Bangalore',
        category: 'Tech',
        organizer: 'AI Minds',
        price: 50.00,
        date: DateTime(2025, 8, 10),
        time: const TimeOfDay(hour: 14, minute: 0),
        eventDateTime: DateTime(2025, 8, 10, 14, 0)),
    Event(
        id: '4',
        name: "Abstract Art Exhibition: Colors & Forms",
        imageUrl:
        'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        caption: 'A vibrant display of contemporary art.',
        location: 'Mumbai',
        category: 'Art',
        organizer: 'Art Gallery',
        price: 10.00,
        date: DateTime(2025, 9, 1),
        time: const TimeOfDay(hour: 11, minute: 0),
        eventDateTime: DateTime(2025, 9, 1, 11, 0)),
    // ...add other events
  ];

  int get selectedIndex => _selectedIndex;

  List<Event> get allEvents => [..._userPostedEvents, ..._randomEvents];

  void addPostedEvent(Event newEvent) {
    _userPostedEvents.insert(0, newEvent);
    _selectedIndex = 0;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
