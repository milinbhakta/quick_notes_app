import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quick_notes_app/Util/note_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = (prefs.getStringList('notes') ?? [])
          .map((note) {
            final noteData = jsonDecode(note) as Map<String, dynamic>;
            return Note(
              title: noteData['title'],
              content: noteData['content'],
              timestamp: DateTime.parse(noteData['timestamp']),
            );
          })
          .toList()
          .cast<Note>();
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'notes',
        _notes.map((note) {
          return jsonEncode({
            'title': note.title,
            'content': note.content,
            'timestamp': note.timestamp.toIso8601String(),
          });
        }).toList());
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      _saveNotes();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showNoteDialog(String title, Function(String, String) onSave) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(
                minHeight: 200.0,
                maxWidth: MediaQuery.of(context).size.width * 0.5),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(hintText: 'Title'),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(hintText: 'Content'),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    String title = _titleController.text;
                    String content = _contentController.text;
                    _titleController.clear();
                    _contentController.clear();
                    onSave(title, content);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNote() {
    _showNoteDialog('New Note', (String title, String content) {
      setState(() {
        _notes.add(
            Note(title: title, content: content, timestamp: DateTime.now()));
        _saveNotes();
      });
    });
  }

  void _updateNote(int index) {
    _titleController.text = _notes[index].title;
    _contentController.text = _notes[index].content;

    _showNoteDialog('Update Note', (String title, String content) {
      setState(() {
        _notes[index] =
            Note(title: title, content: content, timestamp: DateTime.now());
        _saveNotes();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_notes[index].title),
            subtitle: Text(_notes[index].content),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      right: 10.0), // Adjust the value as needed
                  child: Text(
                    'Last updated: ${DateFormat('yyyy-MM-dd – kk:mm').format(_notes[index].timestamp)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _updateNote(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteNote(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
