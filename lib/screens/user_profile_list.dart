// import 'dart:ui'; // Still needed for ImageFilter.blur if you were to use it elsewhere, but not for these buttons now.
//
// import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
//
// class UserProfile extends StatefulWidget {
//   final String title;
//   final String imageUrl;
//   final String category;
//   final String userName;
//   final String location;
//   final String userAvatarUrl;
//
//   const UserProfile({
//     super.key,
//     required this.title,
//     required this.imageUrl,
//     required this.category,
//     required this.userName,
//     required this.location,
//     required this.userAvatarUrl,
//   });
//
//   @override
//   State<UserProfile> createState() => _UserProfileState();
// }
//
// class _UserProfileState extends State<UserProfile> {
//   bool isLiked = false;
//   // int likeCount = 0; // Keeping this if you plan to display a count, otherwise remove.
//
//   void toggleLike() {
//     setState(() {
//       isLiked = !isLiked;
//       // likeCount += isLiked ? 1 : -1; // Uncomment if you use likeCount.
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 380,
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         image: DecorationImage(
//           image: NetworkImage(widget.imageUrl),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Stack(
//         children: [
//           // Dark gradient overlay for text visibility
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(24),
//               gradient: LinearGradient(
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//                 colors: [
//                   Colors.black.withOpacity(0.5),
//                   Colors.transparent,
//                 ],
//               ),
//             ),
//           ),
//
//           // Category Tag
//           Positioned(
//             top: 16,
//             left: 16,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.travel_explore,
//                       size: 16, color: Colors.green),
//                   const SizedBox(width: 4),
//                   Text(
//                     widget.category,
//                     style: const TextStyle(fontSize: 12, color: Colors.black87),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Main title text (question)
//           Positioned(
//             left: 16,
//             right: 80, // Kept this to make space for the right-side buttons
//             bottom: 100,
//             child: Text(
//               widget.title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//
//           // User Profile Info
//           Positioned(
//             left: 16,
//             bottom: 16,
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundImage: NetworkImage(widget.userAvatarUrl),
//                 ),
//                 const SizedBox(width: 10),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.userName,
//                       style: const TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       widget.location,
//                       style:
//                           const TextStyle(color: Colors.white70, fontSize: 12),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//
//           // Vertical Action Buttons (Right side) - Background removed
//           Positioned(
//             right: 16,
//             bottom: 100,
//             child: Column(
//               // Directly use Column without ClipRRect, BackdropFilter, and their Container properties
//               children: [
//                 GestureDetector(
//                   onTap: toggleLike,
//                   child: Icon(
//                     isLiked ? Ionicons.heart : Ionicons.heart_outline,
//                     color: isLiked ? Colors.red : Colors.white,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Icon(Ionicons.chatbubble_outline,
//                     color: Colors.white, size: 26),
//                 const SizedBox(height: 16),
//                 const Icon(Ionicons.share_social_outline,
//                     color: Colors.white, size: 26),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
