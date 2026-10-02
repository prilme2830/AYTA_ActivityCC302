import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

const String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

/// GET: fetch the list of events.
Future<List<Event>> fetchEvents() async {
  final response = await http.get(Uri.parse('$_baseUrl?_limit=6'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((item) => Event.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  throw Exception('Failed to load events (${response.statusCode})');
}

/// DELETE: remove an event by id.
/// (JSONPlaceholder is a fake API: it replies 200 but does not really delete.)
Future<void> deleteEvent(int id) async {
  final response = await http.delete(Uri.parse('$_baseUrl/$id'));

  if (response.statusCode != 200) {
    throw Exception('Failed to delete event (${response.statusCode})');
  }
}
