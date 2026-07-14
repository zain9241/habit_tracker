import 'package:flutter/material.dart';

import 'login_screen.dart';

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

  static const List<Color> _presetColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

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

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
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

  void _showAddHabitDialog() {
    final habitController = TextEditingController();
    Color selectedColor = _presetColors[0];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Habit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: habitController,
                    autofocus: true,
                    decoration:
                    const InputDecoration(labelText: 'Habit name'),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: _presetColors.map((color) {
                      final isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedColor = color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 16,
                          child: isSelected
                              ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final habitName = habitController.text.trim();
                    if (habitName.isEmpty) return;

                    setState(() {
                      selectedHabitsMap[habitName] = _colorToHex(selectedColor);
                    });
                    _saveHabits();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
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
          _buildDrawerItem(Icons.settings, 'Configure'),
          _buildDrawerItem(Icons.person_outline, 'Personal Info'),
          _buildDrawerItem(Icons.bar_chart, 'Reports', badged: true),
          _buildDrawerItem(Icons.notifications_none, 'Notifications'),
          _buildDrawerItem(
            Icons.logout,
            'Sign Out',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  child: _buildHabitCard(habit, habitColor),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  child: _buildHabitCard(habit, habitColor,
                      isCompleted: true),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        backgroundColor: Colors.blue.shade700,
        tooltip: 'Add Habits',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitCard(String title, Color color,
      {bool isCompleted = false}) {
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
          trailing: isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
              : null,
        ),
      ),
    );
  }
}