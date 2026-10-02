import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> _eventsFuture;

  // Events created by the user are stored locally in this list.
  final List<Event> _customEvents = [];

  @override
  void initState() {
    super.initState();
    _eventsFuture = fetchEvents();
  }

  void _retry() {
    setState(() {
      _eventsFuture = fetchEvents();
    });
  }

  Future<void> _handleDelete(List<Event> events, Event event) async {
    // Custom events have negative IDs, so they do not need an API request.
    if (event.id < 0) {
      setState(() {
        _customEvents.remove(event);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${event.eventTitle}"')),
      );
      return;
    }

    try {
      await deleteEvent(event.id);
      setState(() => events.remove(event));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${event.eventTitle}"')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
    }
  }

  Future<void> _showAddCustomEventDialog() async {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    final venueController = TextEditingController();
    final organizerController = TextEditingController();
    final descriptionController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    final newEvent = await showDialog<Event>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Custom Event'),
          content: SizedBox(
            width: 450,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        prefixIcon: Icon(Icons.event),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter an event title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        hintText: 'e.g. October 15, 2026',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter the event date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: venueController,
                      decoration: const InputDecoration(
                        labelText: 'Venue',
                        prefixIcon: Icon(Icons.place),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter the venue';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: organizerController,
                      decoration: const InputDecoration(
                        labelText: 'Organizer',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter the organizer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                Navigator.pop(
                  dialogContext,
                  Event(
                    // Negative IDs identify locally-created custom events.
                    id: -(DateTime.now().millisecondsSinceEpoch),
                    eventTitle: titleController.text.trim(),
                    date: dateController.text.trim(),
                    venue: venueController.text.trim(),
                    organizer: organizerController.text.trim(),
                    image:
                        'https://picsum.photos/seed/custom${DateTime.now().millisecondsSinceEpoch}/600/300',
                    description: descriptionController.text.trim().isEmpty
                        ? 'Custom campus event'
                        : descriptionController.text.trim(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Event'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    dateController.dispose();
    venueController.dispose();
    organizerController.dispose();
    descriptionController.dispose();

    if (newEvent != null) {
      setState(() {
        _customEvents.add(newEvent);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${newEvent.eventTitle}" added to Custom Events')),
      );
    }
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomEventDialog,
        icon: const Icon(Icons.add),
        label: const Text('Custom Event'),
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Something went wrong:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final apiEvents = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _eventsFuture = fetchEvents();
              });
              await _eventsFuture;
            },
            child: ListView(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 100,
              ),
              children: [
                _sectionTitle('Custom Event List', Icons.edit_calendar),

                if (_customEvents.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No custom events yet.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap "Custom Event" to create your own event.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._customEvents.map(
                    (event) => EventCard(
                      event: event,
                      onToggleJoin: () {
                        setState(() {
                          event.isJoined = !event.isJoined;
                        });
                      },
                      onDelete: () => _handleDelete(_customEvents, event),
                    ),
                  ),

                _sectionTitle('Campus Events', Icons.public),

                if (apiEvents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('No campus events found.')),
                  )
                else
                  ...apiEvents.map(
                    (event) => EventCard(
                      event: event,
                      onToggleJoin: () {
                        setState(() {
                          event.isJoined = !event.isJoined;
                        });
                      },
                      onDelete: () => _handleDelete(apiEvents, event),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
