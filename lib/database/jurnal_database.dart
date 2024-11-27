import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';
import '../models/jurnal.dart';

class JournalDatabase extends ChangeNotifier {
  late Box<Journal> _journalsBox;
  late Box<AppSettings> _settingsBox;

  final List<Journal> _journals = [];
  List<Journal> get journals => List.unmodifiable(_journals);

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return; // Skip if already initialized

    try {
      await Hive.initFlutter(); // Initialize Hive

      // Open required boxes
      _journalsBox = await _openBox<Journal>('journals');
      _settingsBox = await _openBox<AppSettings>('settings');

      // Load journals into memory after opening the boxes
      _loadJournalsToMemory();

      _isInitialized = true; // Mark as initialized
      notifyListeners(); // Notify listeners to refresh UI
    } catch (e) {
      debugPrint('Error initializing JournalDatabase: $e');
      rethrow; // Rethrow the error to inform the caller
    }
  }

  Future<Box<T>> _openBox<T>(String boxName) async {
    try {
      return Hive.isBoxOpen(boxName)
          ? Hive.box<T>(boxName)
          : await Hive.openBox<T>(boxName);
    } catch (e) {
      debugPrint('Error opening box "$boxName": $e');
      rethrow; // Rethrow the error to inform the caller
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      throw Exception('JournalDatabase not initialized');
    }
  }

  void _loadJournalsToMemory() {
    _journals.clear(); // Clear the current in-memory list
    _journals.addAll(_journalsBox.values); // Load from the Hive box
  }

  Future<void> createJournal(String title, String content,
      {String? imagePath}) async {
    await _ensureInitialized();

    if (title.trim().isEmpty || content.trim().isEmpty) {
      throw Exception('Title and content cannot be empty');
    }

    try {
      final journal =
          Journal.create(title.trim(), content.trim(), imagePath: imagePath);
      final key = await _journalsBox.add(journal); // Add journal to Hive box
      journal.key = key; // Store Hive key in journal object

      _journals.add(journal); // Add to in-memory list
      notifyListeners(); // Refresh UI
    } catch (e) {
      debugPrint('Error creating journal: $e');
      rethrow;
    }
  }

  Future<void> updateJournal(
      int key, String newContent, String title, String? imagePath,
      {String? newTitle, String? newImagePath}) async {
    await _ensureInitialized();

    try {
      final journal = _journalsBox.get(key);

      if (journal == null) {
        throw Exception('Journal not found');
      }

      journal.content = newContent.trim();
      if (newTitle != null) {
        journal.title = newTitle.trim(); // Make sure 'title' is mutable
      }
      if (newImagePath != null) {
        journal.imagePath = newImagePath; // Ensure 'imagePath' is mutable
      }

      await _journalsBox.put(key, journal); // Update journal in Hive box

      // Update the journal in the in-memory list
      final index = _journals.indexWhere((j) => j.key == key);
      if (index != -1) {
        _journals[index] = journal;
      }

      notifyListeners(); // Refresh UI
    } catch (e) {
      debugPrint('Error updating journal: $e');
      rethrow;
    }
  }

  Future<void> deleteJournal(int key) async {
    await _ensureInitialized();

    try {
      final journal = _journalsBox.get(key);

      if (journal == null) {
        throw Exception('Journal not found');
      }

      await _journalsBox.delete(key); // Delete from Hive box
      _journals.removeWhere((j) => j.key == key); // Remove from in-memory list

      notifyListeners(); // Refresh UI
    } catch (e) {
      debugPrint('Error deleting journal: $e');
      rethrow;
    }
  }

  Future<void> saveFirstLaunchDate() async {
    try {
      final settings = _settingsBox.get('settings');
      if (settings == null) {
        final newSettings = AppSettings.createDefault(); // Use factory method
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

  @override
  Future<void> dispose() async {
    if (_journalsBox.isOpen) await _journalsBox.close();
    if (_settingsBox.isOpen) await _settingsBox.close();
    _isInitialized = false;
    debugPrint('JournalDatabase resources disposed.');
    super.dispose();
  }
}
