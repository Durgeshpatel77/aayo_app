import 'package:flutter/cupertino.dart';

import '../../models/create_event_model.dart';

class EventCreationProvider with ChangeNotifier {
  final List<EventModel> _createdEvents = [];

  List<EventModel> get createdEvents => _createdEvents;

  void addEvent(EventModel event) {
    _createdEvents.add(event);
    notifyListeners();
  }
}
