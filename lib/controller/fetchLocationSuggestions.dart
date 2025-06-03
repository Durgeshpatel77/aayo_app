import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchLocationSuggestions(String query) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=10',
  );

  final response = await http.get(url, headers: {
    'User-Agent': 'FlutterApp (your_email@example.com)' // required by Nominatim
  });

  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.map((item) => item['display_name'] as String).toList();
  } else {
    throw Exception('Failed to load suggestions');
  }
}
