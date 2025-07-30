import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/event_registration_model.dart';
import '../home_screens/single_user_profile_screen.dart';

// Global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class StatusUserListPage extends StatelessWidget {
  final String title;
  final List<EventRegistration> users;

  const StatusUserListPage({super.key, required this.title, required this.users});

  Color _getColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$title Users"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              if (users.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No users to export.')),
                );
                return;
              }

              await _exportToExcel(context);
            },
          ),
        ],
      ),
      body: users.isEmpty
          ? const Center(child: Text("No users in this status."))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final reg = users[index];
          final color = _getColor(reg.status);
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SingleUserProfileScreen(userId: reg.id),
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundColor: Colors.pink.shade100,
                child: const Icon(Icons.person, color: Colors.pink),
              ),
              title: Text(
                reg.name,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  reg.status.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        if (!await Permission.manageExternalStorage.request().isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      }

      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];
      sheet.name = 'Users';

      sheet.getRangeByName('A1').setText('Name');
      sheet.getRangeByName('B1').setText('User ID');
      sheet.getRangeByName('C1').setText('Status');

      for (int i = 0; i < users.length; i++) {
        final row = i + 2;
        sheet.getRangeByName('A$row').setText(users[i].name);
        sheet.getRangeByName('B$row').setText(users[i].id);
        sheet.getRangeByName('C$row').setText(users[i].status);
      }

      final bytes = workbook.saveAsStream();
      workbook.dispose();

      final downloadsDir = Directory('/storage/emulated/0/Download');

      // ✅ Dynamic file name using timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeTitle = title.replaceAll(' ', '_');
      final fileName = '${safeTitle}_users_$timestamp.xlsx';
      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      debugPrint('📂 File saved at: $filePath');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel saved in Downloads:\n$fileName')),
      );

      await _showDownloadNotification(filePath, fileName);
    } catch (e) {
      debugPrint('❌ Export failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export Excel')),
      );
    }
  }

  Future<void> _showDownloadNotification(String filePath, String fileName) async {
    const androidDetails = AndroidNotificationDetails(
      'excel_channel',
      'Excel Downloads',
      channelDescription: 'Excel file download alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Excel Downloaded',
      'Tap to open folder',
      notificationDetails,
      payload: filePath,
    );
  }
}
