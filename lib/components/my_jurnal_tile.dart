import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/jurnal.dart';

class MyJournalTile extends StatelessWidget {
  final Journal journal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyJournalTile({
    super.key,
    required this.journal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (journal.imagePath != null && journal.imagePath!.isNotEmpty) {
      imageWidget = kIsWeb
          ? Image.network(journal.imagePath!, width: 50, height: 50)
          : Image.file(File(journal.imagePath!), width: 50, height: 50);
    } else {
      imageWidget = const Icon(Icons.article, size: 50);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(journal.title),
        subtitle: Text(journal.content),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: imageWidget,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
