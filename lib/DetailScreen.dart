import 'package:flutter/material.dart';

/// A typed model for items shown in the list and detail screens.
/// Replacing `dynamic`/`Map` with this class gives compile-time safety:
/// typos in field names or missing fields are caught before runtime.
class ListItem {
  final String title;
  final String description;

  const ListItem({
    required this.title,
    required this.description,
  });

  /// Optional: convenience constructor if your data source (e.g. an API
  /// or local JSON) gives you a Map<String, dynamic>. Keeps the "dynamic"
  /// boundary in exactly one place instead of scattered through the UI.
  factory ListItem.fromMap(Map<String, dynamic> map) {
    return ListItem(
      title: map['title'] as String? ?? 'Untitled',
      description: map['description'] as String? ?? '',
    );
  }
}

class DetailScreen extends StatelessWidget {
  final ListItem item;

  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      // Note: the AppBar already renders a back arrow automatically when
      // this screen is reached via Navigator.push, so a manual "Back to
      // List" button is redundant. Removed for a cleaner UI; add it back
      // if you have a specific UX reason (e.g. a prominent bottom CTA).
    );
  }
}