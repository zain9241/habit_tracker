import 'package:flutter/material.dart';

import 'DetailScreen.dart';
import 'add_habit_screen.dart';

class HabitTrackerScreen extends StatefulWidget {
  final String username;

  const HabitTrackerScreen({super.key, required this.username});

  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  Map<String, String> selectedHabitsMap = {};
  Map<String, String> completedHabitsMap = {};
  String name = '';

  @override
  void initState() {
    super.initState();
    name = widget.username;
  }

  Future<void> _saveHabits() async {
    //save habits to preferences in the future
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add opacity if not included.
    }
    return Color(int.parse('0x$hexColor'));
  }

  Color _getHabitColor(String habit, Map<String, String> habitsMap) {
    String? colorHex = habitsMap[habit];
    if (colorHex != null) {
      try {
        return _getColorFromHex(colorHex);
      } catch (e) {
        print('Error parsing color for $habit: $e');
      }
    }
    return Colors.blue; // Default color in case of error.
  }

  /// Builds a human-readable summary of the user's habits so it can be
  /// passed into DetailScreen's `description` field (since DetailScreen
  /// only accepts a ListItem with title + description, not raw maps).
  String _buildHabitsSummary() {
    final buffer = StringBuffer();

    buffer.writeln('To Do (${selectedHabitsMap.length}):');
    if (selectedHabitsMap.isEmpty) {
      buffer.writeln('  No habits yet.');
    } else {
      for (final habit in selectedHabitsMap.keys) {
        buffer.writeln('  • $habit');
      }
    }

    buffer.writeln();
    buffer.writeln('Done (${completedHabitsMap.length}):');
    if (completedHabitsMap.isEmpty) {
      buffer.writeln('  Nothing completed yet.');
    } else {
      for (final habit in completedHabitsMap.keys) {
        buffer.writeln('  • $habit');
      }
    }

    return buffer.toString().trim();
  }

  void _openConfigureDetail() {
    Navigator.pop(context); // close the drawer first

    final selectedItem = ListItem(
      title: name.isNotEmpty ? name : 'Loading...',
      description: _buildHabitsSummary(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(item: selectedItem),
      ),
    );
  }

  Future<void> _openAddHabitScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        selectedHabitsMap[result['name'] as String] =
        result['color'] as String;
      });
      _saveHabits();
    }
  }

  void _deleteHabit(String habit, {required bool fromCompleted}) {
    setState(() {
      if (fromCompleted) {
        completedHabitsMap.remove(habit);
      } else {
        selectedHabitsMap.remove(habit);
      }
    });
    _saveHabits();
  }

  Widget _buildDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      backgroundColor: const Color(0xFFF4F2FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue.shade600,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: const Text(
              'Menu',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            Icons.settings,
            'Configure',
            onTap: _openConfigureDetail,
          ),
          _buildDrawerItem(Icons.person_outline, 'Personal Info'),
          _buildDrawerItem(Icons.bar_chart, 'Reports', badged: true),
          _buildDrawerItem(Icons.notifications_none, 'Notifications'),
          _buildDrawerItem(
            Icons.logout,
            'Sign Out',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign Out — coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label,
      {bool badged = false, VoidCallback? onTap}) {
    return ListTile(
      leading: badged
          ? Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      )
          : Icon(icon, color: Colors.grey.shade800, size: 26),
      title: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.black87),
      ),
      onTap: onTap ??
              () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label — coming soon')),
            );
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text(
          name.isNotEmpty ? name : 'Loading...',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'To Do 📝',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          selectedHabitsMap.isEmpty
              ? const Expanded(
            child: Center(
              child: Text(
                'Use the + button to create some habits!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: selectedHabitsMap.length,
              itemBuilder: (context, index) {
                String habit = selectedHabitsMap.keys.elementAt(index);
                Color habitColor =
                _getHabitColor(habit, selectedHabitsMap);
                return Dismissible(
                  key: Key(habit),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      String color = selectedHabitsMap.remove(habit)!;
                      completedHabitsMap[habit] = color;
                      _saveHabits();
                    });
                  },
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerRight,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Swipe to Complete',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.check, color: Colors.white),
                      ],
                    ),
                  ),
                  child: _buildHabitCard(
                    habit,
                    habitColor,
                    onDelete: () =>
                        _deleteHabit(habit, fromCompleted: false),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Done ✅🎉',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          completedHabitsMap.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Swipe right on an activity to mark as done.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: completedHabitsMap.length,
              itemBuilder: (context, index) {
                String habit = completedHabitsMap.keys.elementAt(index);
                Color habitColor =
                _getHabitColor(habit, completedHabitsMap);
                return Dismissible(
                  key: Key(habit),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    setState(() {
                      String color = completedHabitsMap.remove(habit)!;
                      selectedHabitsMap[habit] = color;
                      _saveHabits();
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      children: [
                        Icon(Icons.undo, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Swipe to Undo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  child: _buildHabitCard(
                    habit,
                    habitColor,
                    isCompleted: true,
                    onDelete: () =>
                        _deleteHabit(habit, fromCompleted: true),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddHabitScreen,
        backgroundColor: Colors.blue.shade700,
        tooltip: 'Add Habits',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitCard(String title, Color color,
      {bool isCompleted = false, required VoidCallback onDelete}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color,
      child: Container(
        height: 60, // Adjust the height for thicker cards.
        child: ListTile(
          title: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.white, size: 26),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}