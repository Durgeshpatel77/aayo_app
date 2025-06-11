import 'package:flutter/cupertino.dart';

import '../models/Create_Event_model.dart';

class EventCreationProvider with ChangeNotifier {
  final List<EventModel> _createdEvents = [];

  List<EventModel> get createdEvents => _createdEvents;

  void addEvent(EventModel event) {
    _createdEvents.add(event);
    notifyListeners();
  }
}
