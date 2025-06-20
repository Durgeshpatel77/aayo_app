import 'package:flutter/material.dart';

import '../other_for_use/expandable_text.dart';

class VenueDetailPage extends StatelessWidget {
  final Map venue;
  late TransformationController _transformationController;
  late Offset _doubleTapPosition;

   VenueDetailPage({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    _transformationController = TransformationController();

    final detail = venue; // Access top-level directly
    final content = venue['content']??{};
    final images = venue['media'] as List?;
    final capacity = venue['capacity'] ?? 0;
    final imageUrl = images != null && images.isNotEmpty
        ? _fullImageUrl(images[0])
        : null;

    return Scaffold(

      backgroundColor: const Color(0xFFE5EAF1), // Light grey background
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black38,width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: imageUrl != null
                            ? Image.network(
                          imageUrl,
                          height: 500,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        )
                            : Container(
                          height: 500,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image, size: 50, color: Colors.white),
                          ),
                        ),
                      ),
// Top Image with Zoom + Double Tap + Share
                      Stack(
                        children: [
                          GestureDetector(
                            onDoubleTapDown: (details) {
                              _doubleTapPosition = details.localPosition;
                            },
                            onDoubleTap: () {
                              if (_transformationController.value != Matrix4.identity()) {
                                _transformationController.value = Matrix4.identity();
                              } else {
                                final position = _doubleTapPosition;
                                _transformationController.value = Matrix4.identity()
                                  ..translate(-position.dx * 2, -position.dy * 2)
                                  ..scale(3.0);
                              }
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              child: InteractiveViewer(
                                transformationController: _transformationController,
                                minScale: 1.0,
                                maxScale: 4.0,
                                panEnabled: true,
                                child: imageUrl != null
                                    ? Image.network(
                                  imageUrl,
                                  height: 500,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                )
                                    : Container(
                                  height: 500,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image, size: 50, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.share, color: Colors.black87),
                                onPressed: () {
                                  final title = venue['title'] ?? 'Venue';
                                  final city = detail['city'] ?? '';
                                  final url = imageUrl ?? '';
                                  final shareText = "$title\n$city\n$url\n\nCheck this venue out!";
                                  // Share.share(shareText); // Add this if using share package
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                venue['title'] ?? 'Venue Name',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                SizedBox(width: 4),
                                Text("4.8", style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
              
                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              detail['city'] ?? 'Unknown city',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),

// Capacity
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Capacity: $capacity people',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
              SizedBox(height: 20,),
                        // Description
                        ExpandableText(content: venue['content']??'No description available.',textColor: Colors.black87,),

                        const SizedBox(height: 20),
              
                        // Price and Avatars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: "35₹",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: " /person",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
              
                        // Book Now Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("BOOK NOW", style: TextStyle(letterSpacing: 1,color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fullImageUrl(String path) {
    const base = 'http://srv861272.hstgr.cloud:8000';
    if (path.startsWith('http')) return path;
    if (!path.startsWith('/')) path = '/$path';
    return '$base$path';
  }
}
