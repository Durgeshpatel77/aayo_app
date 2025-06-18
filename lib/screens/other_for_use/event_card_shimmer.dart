import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Texts
          Row(
            children: [
              _shimmerWidget(const CircleAvatar(radius: 24, backgroundColor: Colors.white)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerContainer(width: 120, height: 12),
                  const SizedBox(height: 6),
                  _shimmerContainer(width: 80, height: 10),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),

          // Media
          _shimmerContainer(width: double.infinity, height: 180, borderRadius: 12),
          const SizedBox(height: 16),

          // Likes Row
          Row(
            children: [
              _shimmerWidget(const CircleAvatar(radius: 12, backgroundColor: Colors.white)),
              const SizedBox(width: 6),
              _shimmerWidget(const CircleAvatar(radius: 12, backgroundColor: Colors.white)),
              const SizedBox(width: 10),
              _shimmerContainer(width: 100, height: 10),
            ],
          ),
          const SizedBox(height: 16),

          // Actions Row
          Row(
            children: [
              _shimmerIcon(Icons.favorite_border),
              const SizedBox(width: 16),
              _shimmerIcon(Icons.comment_outlined),
              const SizedBox(width: 16),
              _shimmerIcon(Icons.send),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerContainer({
    required double width,
    required double height,
    double borderRadius = 6,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _shimmerIcon(IconData icon) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _shimmerWidget(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}
