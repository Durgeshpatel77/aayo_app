import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    fetchEvents();
    _searchController.addListener(fetchEvents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                            });
                            Navigator.pop(context);
                            fetchAllEvents();
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
    if (url == 'http://82.29.167.118:8000/api/post') {
      return fetchAllEvents();
    }

    try {
      final response = await http.get(Uri.parse(url));
      print("print search body${response.body}");
      print("print search url${url}");
      print("print search statuscode${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // if (decoded is Map && decoded['data'] is List) {
          setState(() {
            events = decoded['data'];
          });
    //    }
      }
    }
    catch (e) {
      debugPrint('❌ Error fetching events: $e');
    }
  }

  Future<void> fetchAllEvents() async {
    const url = 'http://82.29.167.118:8000/api/post';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          events = decoded['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching all dgfg: $e');
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
                  _buildFilterChip(Icons.tune, 'Filter', onTap: _showAllFilters),
                  _buildFilterChip(
                      Icons.category, selectedCategory ?? 'Category',
                      onTap: _showCategoryPicker),
                  _buildFilterChip(
                      Icons.date_range,
                      selectedDate == null
                          ? 'Date'
                          : DateFormat('dd MMM').format(selectedDate!),
                      onTap: _pickDate),
                  _buildFilterChip(Icons.access_time, selectedPrice ?? 'Time',
                      onTap: _showPricePicker),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 🔹 4. EVENT LIST CONTINUES...
            Expanded(
              child: events.isEmpty
                  ? const Center(child: Text("No events found"))
                  : ListView.builder(
                      itemCount: events.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final e = events[index];
                        final isFree = e['eventDetails']?['isFree'] == true;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              e['title'] ?? 'Untitled',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              isFree ? 'Free Event' : 'Paid Event',
                              style: TextStyle(
                                  color: isFree ? Colors.green : Colors.pink),
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 18),
                          ),
                        );
                      },
                    ),
            ),
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
}
