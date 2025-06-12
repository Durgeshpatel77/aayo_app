// screens/SettingsScreen.dart
import 'package:aayo/screens/setting_screens/about_us_screen.dart';
import 'package:aayo/screens/setting_screens/add_venue_screen.dart';
import 'package:aayo/screens/setting_screens/create_event_screen.dart';
import 'package:aayo/screens/setting_screens/saved_events_screen.dart';
import 'package:aayo/screens/setting_screens/write_to_usscreen.dart';
import 'package:flutter/material.dart';

import '../login_and_onbording_screens/logout_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        // Apply padding directly to ListView
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        children: [
          // Option: Create Event Screen
          ListTile(
            // Updated icon, color, and size to match the desired style
            leading: Icon(Icons.event, color: Colors.grey[700], size: 28),
            title: const Text(
              'Create New Event',
              // Updated font size and weight
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            // Added a subtitle
            subtitle: Text(
              'Plan and publish your next event',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            // Updated trailing icon and color
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateEventScreen()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8), // Divider after the item
          // Option: Add Venue Screen
          ListTile(
            // Updated icon, color, and size
            leading: Icon(Icons.location_on_outlined,
                color: Colors.grey[700], size: 28),
            title: const Text(
              'Add Venue',
              // Updated font size and weight
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            // Added a subtitle
            subtitle: Text(
              'Contribute new locations for events',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            // Updated trailing icon and color
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddVenueScreen()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8), // Divider after the item
          // Option: Saved Events
          ListTile(
            // Updated icon, color, and size
            leading:
                Icon(Icons.bookmark_border, color: Colors.grey[700], size: 28),
            title: const Text(
              'Saved Events',
              // Updated font size and weight
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            // Added a subtitle
            subtitle: Text(
              'View your bookmarked and favorite events',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            // Updated trailing icon and color
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SavedEventsScreen()),
              );
            },
          ),
          // Divider after the item
          // Logical grouping divider as per your original code (can be adjusted)
          const Divider(height: 1, thickness: 1), // Thicker divider for section separation

          // Option: Write to us
          ListTile(
            // Updated icon, color, and size
            leading:
                Icon(Icons.mail_outline, color: Colors.grey[700], size: 28),
            title: const Text(
              'Write to Us',
              // Updated font size and weight
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            // Added a subtitle
            subtitle: Text(
              'Send us your feedback or support queries',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            // Updated trailing icon and color
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  WriteToUsScreen()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8), // Divider after the item
          // Option: About us
          ListTile(
            // Updated icon, color, and size
            leading:
                Icon(Icons.info_outline, color: Colors.grey[700], size: 28),
            title: const Text(
              'About Us',
              // Updated font size and weight
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            // Added a subtitle
            subtitle: Text(
              'Learn more about the Aayo App',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            // Updated trailing icon and color
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8), // Divider after the last item (optional)
          //Option:logout
          ListTile(
            // Updated icon, color, and size to match the desired style
            leading: Icon(Icons.logout, color: Colors.grey[700], size: 28),
            title: const Text(
              'Logout',
              // Updated font size and weight
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            // Added a subtitle
            subtitle: Text(
              ("Tap to sign out of your account"),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            // Updated trailing icon and color
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LogoutScreen()),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.8), // Divider after the item

        ],
      ),
    );
  }
}
