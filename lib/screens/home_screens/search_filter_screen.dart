import 'package:aayo/screens/home_screens/post_detail_screens.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../models/event_model.dart';
import '../event_detail_screens/events_details.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? selectedDate;
  String? selectedTagSlug;
  String? selectedCategory;
  String? selectedPrice;
  String? selectedType; // can be 'event', 'post', or null
  String _getTypeLabel() {
    if (selectedType == null) return 'Type';
    if (selectedType == 'event') return 'Event';
    if (selectedType == 'post') return 'Post';
    return 'Type';
  }


  final List<Map<String, String>> categories = [
    {'icon': '💼', 'title': 'Business', 'slug': 'business'},
    {'icon': '🙌', 'title': 'Community', 'slug': 'community'},
    {
      'icon': '🎵',
      'title': 'Music & Entertainment',
      'slug': 'music-entertainment'
    },
    {'icon': '🩹', 'title': 'Health', 'slug': 'health'},
    {'icon': '🍟', 'title': 'Food & drink', 'slug': 'food-drink'},
    {
      'icon': '👨‍👩‍👧‍👦',
      'title': 'Family & Education',
      'slug': 'family-education'
    },
    {'icon': '⚽', 'title': 'Sport', 'slug': 'sport'},
    {'icon': '👠', 'title': 'Fashion', 'slug': 'fashion'},
    {'icon': '🎬', 'title': 'Film & Media', 'slug': 'film-media'},
    {'icon': '🏠', 'title': 'Home & Lifestyle', 'slug': 'home-lifestyle'},
    {'icon': '🎨', 'title': 'Design', 'slug': 'design'},
    {'icon': '🎮', 'title': 'Gaming', 'slug': 'gaming'},
    {'icon': '🧪', 'title': 'Science & Tech', 'slug': 'science-tech'},
    {'icon': '🏫', 'title': 'School & Education', 'slug': 'school-education'},
    {'icon': '🏖️', 'title': 'Holiday', 'slug': 'holiday'},
    {'icon': '✈️', 'title': 'Travel', 'slug': 'travel'},
  ];

  List events = [];
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(fetchEvents);
    if (_searchController.text.trim().isNotEmpty) {
      fetchEvents();
    }

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  bool _hasActiveFilters() {
    return _searchController.text.trim().isNotEmpty ||
        selectedDate != null ||
        selectedPrice != null ||
        selectedTagSlug != null ||
        selectedType != null;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchEvents();
    }
  }
  void _showAllFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'All Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 Category Picker
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Category',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: categories.map((cat) {
                      final isSelected = selectedTagSlug == cat['slug'];
                      return ChoiceChip(
                        label: Text('${cat['icon']} ${cat['title']}'),
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() {
                            selectedCategory = cat['title'];
                            selectedTagSlug = cat['slug'];
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Date Picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.date_range),
                    title: Text(selectedDate == null
                        ? 'Select Date'
                        : DateFormat('dd MMM yyyy').format(selectedDate!)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),

                  // 🔹 Price Picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Price'),
                    trailing: DropdownButton<String>(
                      value: selectedPrice,
                      hint: const Text("Select"),
                      items: ['Free', 'Paid'].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() => selectedPrice = value);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = null;
                              selectedTagSlug = null;
                              selectedDate = null;
                              selectedPrice = null;
                              _searchController.clear(); // Clear search
                            });
                            Navigator.pop(context);
                            fetchEvents(); // <- use this instead to respect cleared search
                          },
                          child: const Text('Clear all'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            fetchEvents();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _buildUrl() {
    const baseUrl = 'http://82.29.167.118:8000/api/post';
    List<String> params = [];

    if (selectedTagSlug != null) {
      params.add('tags=${Uri.encodeComponent(selectedTagSlug!)}');
    }

    if (selectedDate != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(selectedDate!);
      params.add('date=$formatted');
    }

    if (selectedPrice != null) {
      final isFree = selectedPrice == 'Free';
      params.add('isFree=$isFree');
    }

    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      params.add('search=$query');
    }

    final url = params.isEmpty ? baseUrl : '$baseUrl?${params.join('&')}';
    return url;
  }

  Future<void> fetchEvents() async {
    final url = _buildUrl();
    print("🔍 print search url $url");

    // ✅ Skip fetch if no filter is applied
    if (!_hasActiveFilters()) {
      setState(() {
        events = [];
        hasSearched = true;
      });
      print("🚫 No filters selected. Skipping fetch.");
      return;
    }

    setState(() {
      hasSearched = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final posts = decoded['data']?['posts'];

        if (posts is List) {
          print("🔁 Posts returned from API: ${posts.length}");

          List filteredPosts = posts.where((post) {
            final details = post['eventDetails'] ?? {};
            final postType = post['type'];

            // ✅ 1. Remove posts when price is selected
            if (selectedPrice != null && postType != 'event') {
              return false;
            }

            // ✅ 2. Match isFree for events only
            if (selectedPrice != null && postType == 'event') {
              final isFreeFromBackend = details['isFree'];
              if (selectedPrice == 'Free' && isFreeFromBackend != true) {
                return false;
              }
              if (selectedPrice == 'Paid' && isFreeFromBackend != false) {
                return false;
              }
            }

            // ✅ 3. Type match
            final typeMatch =
                selectedType == null || postType == selectedType;

            // ✅ 4. Date match (only for events)
            bool dateMatch = true;
            if (selectedDate != null) {
              if (postType == 'event' && details['startTime'] != null) {
                try {
                  final eventDate =
                  DateTime.parse(details['startTime']).toLocal();
                  final selected =
                  DateFormat('yyyy-MM-dd').format(selectedDate!);
                  final postDate = DateFormat('yyyy-MM-dd').format(eventDate);
                  dateMatch = selected == postDate;
                } catch (_) {
                  dateMatch = false;
                }
              } else {
                dateMatch = false;
              }
            }

            final result = typeMatch && dateMatch;
            if (result) {
              print("👀 Showing: ${post['type']} - ${post['title']} - isFree: ${details['isFree']}");
            }

            return result;
          }).toList();

          setState(() {
            events = filteredPosts;
          });
        } else {
          print("❌ posts is not a List");
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Error fetching events: $e');
    }
  }

  Future<void> fetchAllEvents() async {
    const url = 'http://82.29.167.118:8000/api/post';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final posts = decoded['data']?['posts'];
        if (posts is List) {
          setState(() {
            events = posts;
          });
        } else {
          debugPrint('❌ Unexpected data format: posts is not a List');
        }
      } else {
        debugPrint('❌ Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching all events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Events and Posts ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 1. HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            ),

            // 🔹 2. SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => fetchEvents(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'What do you feel like doing?',
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          fetchEvents();
                        },
                      )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 3. FILTER ROW
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildFilterChip(
                      Icons.category, selectedCategory ?? 'Category',
                      onTap: _showCategoryPicker),
                  _buildFilterChip(
                      Icons.date_range,
                      selectedDate == null
                          ? 'Date'
                          : DateFormat('dd MMM').format(selectedDate!),
                      onTap: _pickDate),
                  _buildFilterChip(Icons.currency_rupee, selectedPrice ?? 'price',
                      onTap: _showPricePicker),

                  _buildFilterChip(Icons.swap_horiz, _getTypeLabel(),
                      onTap: _showTypePicker),

                ],
              ),
            ),

            const SizedBox(height: 8),
            if (selectedDate != null ||
                selectedCategory != null ||
                selectedPrice != null ||
                selectedType != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (selectedCategory != null)
                      Chip(
                        label: Text("Category: $selectedCategory"),
                        onDeleted: () {
                          setState(() {
                            selectedCategory = null;
                            selectedTagSlug = null;
                          });
                          fetchEvents();
                        },
                      ),
                    if (selectedDate != null)
                      Chip(
                        label: Text("Date: ${DateFormat('dd MMM').format(selectedDate!)}"),
                        onDeleted: () {
                          setState(() => selectedDate = null);
                          fetchEvents();
                        },
                      ),
                    if (selectedPrice != null)
                      Chip(
                        label: Text("Price: $selectedPrice"),
                        onDeleted: () {
                          setState(() => selectedPrice = null);
                          fetchEvents();
                        },
                      ),
                    if (selectedType != null)
                      Chip(
                        label: Text("Type: ${selectedType!.capitalize()}"),
                        onDeleted: () {
                          setState(() => selectedType = null);
                          fetchEvents();
                        },
                      ),
                  ],
                ),
              ),

            // 🔹 4. EVENT LIST CONTINUES...
            Expanded(
              child: hasSearched
                  ? (events.isEmpty
                  ? const Center(child: Text("No events found"))
                  : ListView.builder(
                itemCount: events.length,
                  itemBuilder: (context, index) {
                    final item = events[index];
                    final type = item['type'] ?? 'unknown';
                    final user = item['user'] ?? {};
                    final media = item['media'] ?? [];
                    final eventDetails = item['eventDetails'] ?? {};
                    final tags = item['tags'] ?? [];

                    final isFree = eventDetails['isFree'] == true;

                    return InkWell(
                      onTap: () {
                        if (type == 'event') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(event: Event.fromJson(item)),
                            ),
                          );
                        } else if (type == 'post') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(post: Event.fromJson(item)),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: type == 'event'
                                        ? Colors.pink.shade100
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    type.toUpperCase(),
                                    style: TextStyle(
                                      color: type == 'event' ? Colors.pink : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['title'] ?? 'No Title',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(
                                      'http://82.29.167.118:8000/${user['profile'] ?? ''}',
                                    ),
                                    onBackgroundImageError: (_, __) {},
                                  ),
                                  const SizedBox(width: 8),
                                  Text(user['name'] ?? 'Unknown',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (tags.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  children: tags.map<Widget>((tag) {
                                    return Chip(
                                      label: Text(tag),
                                      backgroundColor: Colors.grey.shade200,
                                      visualDensity: VisualDensity.compact,
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                item['content'] ?? '',
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              if (type == 'event') ...[
                                const Divider(),
                                Text("📍 ${eventDetails['location'] ?? 'No location'}",
                                    style: const TextStyle(fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  "🗓️ ${eventDetails['startTime']?.toString().substring(0, 10) ?? ''} - ${eventDetails['endTime']?.toString().substring(0, 10) ?? ''}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isFree
                                      ? "💸 Free"
                                      : "💸 ₹${eventDetails['price'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isFree ? Colors.green : Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              if (media.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      'http://82.29.167.118:8000/${media.first}',
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              ))
                  : const Center(child: Text("Search or apply filter to view results")),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.pink.shade100),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.black)),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
  void _showTypePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['All', 'Event', 'Post'].map((option) {
          return ListTile(
            title: Text(option),
            onTap: () {
              setState(() {
                selectedType = option == 'All' ? null : option.toLowerCase();
              });
              Navigator.pop(context);
              fetchEvents();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((cat) {
            return ChoiceChip(
              label: Text('${cat['icon']} ${cat['title']}'),
              selected: selectedTagSlug == cat['slug'],
              onSelected: (_) {
                setState(() {
                  selectedCategory = cat['title'];
                  selectedTagSlug = cat['slug'];
                });
                Navigator.pop(context);
                fetchEvents();
              },
              selectedColor: Colors.pink[300],
              backgroundColor: Colors.grey[200],
              labelStyle: const TextStyle(color: Colors.black),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPricePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Free', 'Paid'].map((option) {
          return ListTile(
            title: Text(option),
            onTap: () {
              setState(() => selectedPrice = option);
              Navigator.pop(context);
              fetchEvents();
            },
          );
        }).toList(),
      ),
    );
  }
}

Widget _buildFilterChip(IconData icon, String label,
    {required VoidCallback onTap}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.black),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.black),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black, size: 16),
          ],
        ),
      ),
    ),
  );
}extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
