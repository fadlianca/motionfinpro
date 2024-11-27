import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../components/my_jurnal_tile.dart';
import '../database/jurnal_database.dart';
import '../models/jurnal.dart';
import '../services/jurnal_services.dart';
import '../util/jurnal_util.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late JournalDatabase journalDatabase;
  late Box<Journal> journalBox;
  late Future<void> _initFuture;
  late Future<List<String>> _journalingIdeasFuture; // API Ninjas ideas

  final JournalService journalService =
      JournalService(); // Updated to JournalService

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeHive();
    _journalingIdeasFuture =
        _fetchJournalIdeas(); // Fetch journaling ideas from API Ninjas
  }

  Future<void> _initializeHive() async {
    journalBox = await Hive.openBox<Journal>('journals');
    journalDatabase = JournalDatabase();
    await journalDatabase.init();
  }

  // Fetch journal ideas from API Ninjas
  Future<List<String>> _fetchJournalIdeas() async {
    try {
      return await journalService
          .fetchJournalingIdeas(); // Fetch from API Ninjas
    } catch (e) {
      throw Exception('Failed to fetch journaling ideas: $e');
    }
  }

  // Function to trigger a refresh of journal ideas
  void _refreshJournalIdeas() {
    setState(() {
      _journalingIdeasFuture = _fetchJournalIdeas(); // Trigger re-fetch
    });
  }

  /// Show bottom sheet to create or edit a journal entry
  void _showJournalForm({Journal? existingJournal}) {
    final titleController = TextEditingController(
      text: existingJournal?.title ?? '',
    );
    final contentController = TextEditingController(
      text: existingJournal?.content ?? '',
    );
    String? imagePath = existingJournal?.imagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final pickedImagePath = await JournalUtils.pickImage();
                      if (pickedImagePath != null) {
                        setState(() {
                          imagePath = pickedImagePath;
                        });
                      }
                    },
                    child: const Text('Pick Image'),
                  ),
                  if (imagePath != null) ...[
                    const SizedBox(width: 10),
                    const Text('Image selected'),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!JournalUtils.validateInputs(
                      titleController.text, contentController.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  try {
                    if (existingJournal == null) {
                      // Create a new journal
                      await journalDatabase.createJournal(
                        titleController.text,
                        contentController.text,
                        imagePath: imagePath,
                      );
                    } else {
                      // Update an existing journal
                      final updatedJournal = existingJournal.copyWith(
                        title: titleController.text,
                        content: contentController.text,
                        imagePath: imagePath,
                      );

                      if (updatedJournal != existingJournal) {
                        await journalDatabase.updateJournal(
                          updatedJournal.key!,
                          updatedJournal.content,
                          updatedJournal.title,
                          updatedJournal.imagePath,
                        );
                      }
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Save Journal'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build the journal list with both local (Hive) and API-based ideas
  Widget _buildJournalList() {
    return ValueListenableBuilder<Box<Journal>>(
      valueListenable: Hive.box<Journal>('journals').listenable(),
      builder: (context, box, _) {
        if (box.values.isEmpty) {
          return const Center(child: Text('No journals available.'));
        }

        final journals = box.values.toList().cast<Journal>();
        return ListView.builder(
          itemCount: journals.length,
          itemBuilder: (context, index) {
            final journal = journals[index];
            return MyJournalTile(
              journal: journal,
              onEdit: () => _showJournalForm(existingJournal: journal),
              onDelete: () async {
                try {
                  await journalBox.delete(journal.key!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Journal deleted')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error initializing journal: ${snapshot.error}'),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('Journal Entries')),
            body: Column(
              children: [
                FutureBuilder<List<String>>(
                  future: _journalingIdeasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No journaling ideas available.'));
                    } else {
                      final ideas = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Suggested Journaling Ideas:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          for (var idea in ideas)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text('- $idea'),
                            ),
                          // Refresh button for new ideas
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ElevatedButton(
                              onPressed: _refreshJournalIdeas,
                              child: const Text('Get New Ideas'),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                Expanded(child: _buildJournalList()),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showJournalForm(),
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
