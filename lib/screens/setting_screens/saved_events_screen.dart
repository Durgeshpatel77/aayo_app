// screens/SavedEventsScreen.dart
import 'package:flutter/material.dart';

class SavedEventsScreen extends StatelessWidget {
  const SavedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Events'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new_sharp)),

      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text('Your saved events will be displayed here.'),
      ),
    );
  }
}
