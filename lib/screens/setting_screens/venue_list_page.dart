import 'package:aayo/screens/setting_screens/venue_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/setting_screens_providers/venue_provider.dart';

class VenueListPage extends StatefulWidget {
  const VenueListPage({super.key});

  @override
  State<VenueListPage> createState() => _VenueListPageState();
}

class _VenueListPageState extends State<VenueListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VenueProvider>().fetchVenues());
  }

  String _fullImageUrl(String path) {
    const base = 'http://srv861272.hstgr.cloud:8000';
    if (path.startsWith('http')) return path;
    if (!path.startsWith('/')) path = '/$path';
    return '$base$path';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VenueProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    int crossAxisCount;
    if (screenWidth >= 1000) {
      crossAxisCount = 4;
    } else if (screenWidth >= 700) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    // ---------- LOADING ----------
    if (provider.isLoadingVenues) {
      return const Scaffold(
        appBar: _AppBar(),
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    // ---------- ERROR ----------
    if (provider.venueFetchError != null) {
      return Scaffold(
        appBar: const _AppBar(),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(provider.venueFetchError!,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.fetchVenues,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ---------- EMPTY ----------
    if (provider.venues.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        appBar: _AppBar(),
        body: Center(child: Text('No venues available.')),
      );
    }

    // ---------- DATA ----------
    return Scaffold(
      appBar: const _AppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: provider.venues.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (_, idx) {
            final v = provider.venues[idx];
            final detail = v; // ✅ FIXED: no venueDetails field
            final images = (v['media'] is List) ? List.from(v['media']) : <String>[];
            final imgUrl = images.isNotEmpty ? _fullImageUrl(images[0]) : '';

            return GestureDetector(
              onTap: () {
                Navigator.pop(context, {
                  'name': v['title'] ?? 'Selected Venue',
                  'address': detail['location'] ?? '',
                  'city': detail['city'] ?? '',

                });
              },
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black38, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- IMAGE ----------
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: imgUrl.isNotEmpty
                          ? Image.network(
                        imgUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _brokenImage(),
                      )
                          : _brokenImage(),
                    ),
                    const SizedBox(height: 8),
                    // ---------- TITLE ----------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        v['title'] ?? 'Venue',
                        style: TextStyle(
                          fontSize: 15 * textScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ---------- ADDRESS ----------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        detail['location'] ?? 'Unknown address',
                        style: TextStyle(
                          fontSize: 13 * textScale,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    // ---------- MORE DETAILS BUTTON ----------
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VenueDetailPage(venue: v),
                              ),
                            );
                          },
                          child: Text(
                            'More Details',
                            style: TextStyle(
                                color: Colors.blue, fontSize: 12 * textScale),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  Widget _brokenImage() => Container(
    height: 120,
    width: double.infinity,
    color: Colors.grey[300],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.image_not_supported,
            color: Colors.black45, size: 40),
        SizedBox(height: 8),
        Text('No image available',
            style: TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    ),
  );
}

// -----------------------------------------------------------------------
class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('Venues'),
    centerTitle: true,
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    scrolledUnderElevation: 0,
    elevation: 0,
    foregroundColor: Colors.black,
  );
}
