import 'package:aayo/models/notification_model.dart';
import 'package:flutter/material.dart';

class Notificationscreen extends StatelessWidget {
  const Notificationscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Notification"),),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today Section
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                "Today",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            NotificationItem(
              icon: Icons.confirmation_num_outlined,
              title: "Got 30% Off on Dance Event!",
              subtitle: "Special promotion only valid today",
              iconBackgroundColor: Colors.pinkAccent,
            ),
            NotificationItem(
              icon: Icons.lock_outline,
              title: "Password Update Successful",
              subtitle: "Your password update successfully",
              iconBackgroundColor: Colors.pinkAccent,
            ),
            const SizedBox(height: 16.0), // Spacing between sections

            // Yesterday Section
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text(
                "Yesterday",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            NotificationItem(
              icon: Icons.person_outline,
              title: "Account Setup Successful!",
              subtitle: "Your account has been created",
              iconBackgroundColor: Colors.pinkAccent,
            ),
            NotificationItem(
              icon: Icons.card_giftcard,
              title: "Redeem your gift card",
              subtitle: "You have got one gift card",
              iconBackgroundColor: Colors.pinkAccent,
            ),
            NotificationItem(
              icon: Icons.credit_card,
              title: "Debit card added successfully",
              subtitle: "Your debit card added successfully",
              iconBackgroundColor: Colors.pinkAccent,
            ),
            const SizedBox(height: 16.0), // Spacing at the bottom
          ],
        ),
      ),
    );
  }
}
