import 'package:flutter/material.dart';
import 'package:flutter_notes_crud/models/note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  NoteDetailScreen({required this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson = prefs.getStringList('notes') ?? [];

    if (widget.note.title.isEmpty && widget.note.content.isEmpty) {
      // Create new note
      Note newNote = Note(
        title: _titleController.text,
        content: _contentController.text,
      );
      notesJson.add(jsonEncode(newNote.toJson()));
    } else {
      // Update existing note
      Note updatedNote = Note(
        title: _titleController.text,
        content: _contentController.text,
      );
      int index = notesJson.indexOf(jsonEncode(widget.note.toJson()));
      if (index != -1) {
        notesJson[index] = jsonEncode(updatedNote.toJson());
      }
    }

    await prefs.setStringList('notes', notesJson);
    Navigator.pop(context, true); // Return true to refresh notes list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title.isEmpty ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveNote();
            },
          ),
          if (widget.note.title.isNotEmpty || widget.note.content.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                List<String> notesJson = prefs.getStringList('notes') ?? [];
                notesJson.remove(jsonEncode(widget.note.toJson()));
                await prefs.setStringList('notes', notesJson);
                Navigator.pop(context, true); // Return true to refresh notes list
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Content',
              ),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}