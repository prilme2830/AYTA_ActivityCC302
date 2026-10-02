class Event {
  final int id; // needed for the DELETE request
  final String eventTitle;
  final String date;
  final String venue;
  final String organizer;
  final String image;
  final String description;

  bool isJoined;

  Event({
    required this.id,
    required this.eventTitle,
    required this.date,
    required this.venue,
    required this.organizer,
    required this.image,
    required this.description,
    this.isJoined = false,
  });

  static const List<String> _venues = [
    'Covered Court',
    'University Gym',
    'Oval Track',
    'Student Center',
    'Activity Hall',
    'Sports Complex',
  ];

  // JSONPlaceholder only provides id, userId, title and body, so the API
  // fields are mapped and the rest are filled in with placeholder values.
  // If you use an API that returns date/venue/organizer/image, read them
  // from `json` here instead.
  factory Event.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int;
    final int userId = json['userId'] as int;

    return Event(
      id: id,
      eventTitle: json['title'] as String,
      description: json['body'] as String,
      organizer: 'Organizer #$userId',
      date: 'Oct ${10 + id}, 2026',
      venue: _venues[id % _venues.length],
      image: 'https://picsum.photos/seed/event$id/600/300',
    );
  }
}
