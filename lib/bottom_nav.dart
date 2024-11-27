import 'package:flutter/material.dart';
import '../pages/habit_page.dart';
import '../pages/jadwal_page.dart';
import '../pages/jurnal_page.dart';
import '../pages/notification_page.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const HabitPage(),
    const JournalPage(),
    JadwalPage(
      selectedDate: DateTime.now(),
    ),
    const NotificationsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor:
            Theme.of(context).colorScheme.tertiary, // Highlighted color
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface, // Muted color
        backgroundColor: Theme.of(context).colorScheme.surface, // Matches page
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Habit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journaling',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
        ],
      ),
    );
  }
}
