import 'package:aayo/screens/event_detail_screens/ordersummart_screen.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../res/app_colors.dart';
import 'approve_screen.dart';
import 'chat_page.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventName;

  const EventDetailScreen({required this.eventName, super.key});
  String generateChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1504609813442-a8924e83f76e?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // The "Manage Access" message, styled as a card/banner
                  Positioned(
                    top: 54,
                    left: 22,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 54,
                    right: 22,
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Positioned(
                    top: 170,
                    left: 16,
                    right: 16,
                    child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // space between title and price
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // align texts at top
                              children: [
                                Expanded(
                                  child: Text(
                                    "Party with friends at night - 2022",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        12), // some spacing between text and price
                                Text(
                                  '\$30.00',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Text(
                                  "Gandhinagar",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Spacer(),
                                SizedBox(
                                  width:
                                      170, // enough width for 6 avatars with overlap
                                  height: 36, // diameter = 2 * radius = 44
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: NetworkImage(
                                              'https://randomuser.me/api/portraits/women/68.jpg'),
                                        ),
                                      ),
                                      Positioned(
                                        left: 30,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: NetworkImage(
                                              'https://randomuser.me/api/portraits/women/65.jpg'),
                                        ),
                                      ),
                                      Positioned(
                                        left: 60,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: NetworkImage(
                                              'https://randomuser.me/api/portraits/women/66.jpg'),
                                        ),
                                      ),
                                      Positioned(
                                        left: 90,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: NetworkImage(
                                              'https://randomuser.me/api/portraits/women/67.jpg'),
                                        ),
                                      ),
                                      Positioned(
                                        left: 120,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.pinkAccent,
                                          radius: 18,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                "40",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Text(
                                  'THU 26 May, 09:00',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      border: Border.all(color: Colors.pink,width: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          'You have manage access for this event',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.pink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ApproveScreen();
                            },));
                          },
                          child: Container(
                            width: screenWidth * 0.2,
                            height: screenHeight * 0.04,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.pink,
                            ),
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Manage",
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.north_east,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
SizedBox(height: 18,),
                  // About Section
                  Text('About',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    'We have a team but still missing a couple of people. Let’s play together!',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 24),
                  Divider(
                    color: Colors.grey.shade200,
                  ),

                  // Organizers and Attendees Section
                  Text('Organizers and Attendees',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      SizedBox(
                        width: 85,
                        height: 50,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                    'https://randomuser.me/api/portraits/women/68.jpg'),
                              ),
                            ),
                            Positioned(
                              left: 35,
                              child: CircleAvatar(
                                backgroundColor: Colors.pinkAccent,
                                radius: 24,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "15",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Organizers',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              )),
                          Text('Wade Warren',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                currentUserId: 'userA',
                                peerUserId: 'userB',
                                peerName: 'John',
                                chatId: generateChatId('userA', 'userB'),
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.forum_outlined,
                          size: 36,
                          color: Colors.pink.shade400,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Divider(
                    color: Colors.grey.shade200,
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  // Location Section
                  Text('Location',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 18),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Background map image (you can keep only one if needed)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'https://media.istockphoto.com/id/1306807452/vector/map-city-vector-illustration.jpg?s=612x612&w=0&k=20&c=8efOIy-Ft3trEzeDk3PY2WRjWws8mvKXgkLqCZ2cP5A=',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // Semi-transparent overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),

                              // Circle icon in center
                              Center(
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.pinkAccent,
                                  child: Icon(
                                    Icons.location_searching_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),

                              // "See Location" button at top-left
                              Positioned(
                                top: 12,
                                left: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle button tap here
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'See Location',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        //fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
,
                  SizedBox(height: 24),

                  // Buy Ticket Button
                  // In your EventDetailScreen (or wherever the "Buy Ticket" button is)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderSummaryScreen(
                            eventName: "Party with friends at night - 2022",
                            eventDate: "THU 26 May",
                            eventTime: "09:00",
                            eventLocation: "Gandhinagar",
                            eventImageUrl:
                                'https://images.unsplash.com/photo-1504609813442-a8924e83f76e?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                            ticketPrice:
                                15.00, // Assuming a single ticket price
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: const Text(
                      'Buy Ticket',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
