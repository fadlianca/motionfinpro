import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';
import '../models/habit.dart';

class HabitDatabase extends ChangeNotifier {
  // Static box instances
  static late Box<Habit> _habitsBox;
  static late Box<AppSettings> _settingsBox;

  // Getter methods for boxes to ensure controlled access
  static Box<Habit> get habitsBox => _habitsBox;
  static Box<AppSettings> get settingsBox => _settingsBox;

  // Private initialization flag
  static bool _isInitialized = false;

  // List to store current habits with a getter
  final List<Habit> _habits = [];
  List<Habit> get habits => List.unmodifiable(_habits);

  // Initialize database
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive boxes
      if (!Hive.isBoxOpen('habits')) {
        _habitsBox = await Hive.openBox<Habit>('habits');
      } else {
        _habitsBox = Hive.box<Habit>('habits');
      }

      if (!Hive.isBoxOpen('settings')) {
        _settingsBox = await Hive.openBox<AppSettings>('settings');
      } else {
        _settingsBox = Hive.box<AppSettings>('settings');
      }

      _isInitialized = true;
      await loadHabits(); // Pre-load habits
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  // Load habits from database
  Future<void> loadHabits() async {
    try {
      _habits.clear();
      _habits.addAll(_habitsBox.values);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading habits: $e');
      rethrow;
    }
  }

  // Create new habit
  Future<void> createHabit(String name) async {
    try {
      // Periksa apakah box terbuka
      if (!_habitsBox.isOpen) {
        throw Exception('Box is not open');
      }

      // Validasi nama habit tidak kosong
      if (name.trim().isEmpty) {
        throw Exception('Habit name cannot be empty');
      }

      // Debugging log
      debugPrint('Attempting to create habit: $name');

      // Buat objek habit baru
      final habit = Habit.create(name.trim());
      debugPrint('Created habit: ${habit.id} - ${habit.name}');

      // Simpan habit ke dalam box
      await _habitsBox.put(habit.id, habit);
      debugPrint('Habit saved successfully');

      // Muat ulang daftar habit
      await loadHabits();
    } catch (e) {
      debugPrint('Error creating habit: $e');
      rethrow;
    }
  }

  // Update habit completion status
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    try {
      final habit = _habitsBox.get(id);
      if (habit == null) throw Exception('Habit not found');

      final today = DateTime.now();
      final dateToday = DateTime(today.year, today.month, today.day);

      if (isCompleted) {
        if (!habit.completedDays.contains(dateToday)) {
          habit.completedDays.add(dateToday);
        }
      } else {
        habit.completedDays.removeWhere((date) =>
            date.year == dateToday.year &&
            date.month == dateToday.month &&
            date.day == dateToday.day);
      }

      await _habitsBox.put(id, habit);
      await loadHabits();
    } catch (e) {
      debugPrint('Error updating habit completion: $e');
      rethrow;
    }
  }

  // Update habit name
  Future<void> updateHabitName(int id, String newName) async {
    try {
      if (newName.trim().isEmpty) {
        throw Exception('Habit name cannot be empty');
      }

      final habit = _habitsBox.get(id);
      if (habit == null) throw Exception('Habit not found');

      habit.name = newName.trim();
      await _habitsBox.put(id, habit);
      await loadHabits();
    } catch (e) {
      debugPrint('Error updating habit name: $e');
      rethrow;
    }
  }

  // Delete habit
  Future<void> deleteHabit(int id) async {
    try {
      final habit = _habitsBox.get(id);
      if (habit == null) throw Exception('Habit not found');

      await _habitsBox.delete(id);
      await loadHabits();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }

  // First launch date operations
  Future<void> saveFirstLaunchDate() async {
    try {
      final settings = _settingsBox.get('settings');
      if (settings == null) {
        final newSettings =
            AppSettings.createDefault(); // Gunakan factory method
        await _settingsBox.put('settings', newSettings);
      }
    } catch (e) {
      debugPrint('Error saving first launch date: $e');
      rethrow;
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    try {
      final settings = _settingsBox.get('settings');
      return settings?.firstLaunchDate;
    } catch (e) {
      debugPrint('Error getting first launch date: $e');
      rethrow;
    }
  }

  // Clean up resources
  @override
  Future<void> dispose() async {
    await _habitsBox.compact();
    await _settingsBox.compact();
    await _habitsBox.close();
    await _settingsBox.close();
    _isInitialized = false;
    super.dispose();
  }
}
