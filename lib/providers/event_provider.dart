import 'dart:io';
import 'package:flutter/material.dart';

class EventPostProvider with ChangeNotifier {
  File? _image;
  String _description = '';
  DateTime? _scheduledDateTime;

  File? get image => _image;
  String get description => _description;
  DateTime? get scheduledDateTime => _scheduledDateTime;

  void setImage(File? file) {
    _image = file;
    notifyListeners();
  }

  void setDescription(String text) {
    _description = text;
    notifyListeners();
  }

  void setScheduledDateTime(DateTime? dateTime) {
    _scheduledDateTime = dateTime;
    notifyListeners();
  }

  void clearAll() {
    _image = null;
    _description = '';
    _scheduledDateTime = null;
    notifyListeners();
  }

  bool get isPostEnabled =>
      _image != null || _description.trim().isNotEmpty || _scheduledDateTime != null;
}
