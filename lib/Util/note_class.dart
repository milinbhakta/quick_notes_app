import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Note {
  String title;
  String content;
  DateTime timestamp;

  Note({required this.title, required this.content, required this.timestamp});
}

class NoteProvider {
  // Make constructor private.
  NoteProvider._privateConstructor() {
    init();
  }

  // Create a static instance of the class.
  static final NoteProvider instance = NoteProvider._privateConstructor();

  // List of notes.
  List<Note> _notes = [];

  // isNotesdeleted
  bool isNotesDeleted = false;

  // Getter for notes.
  List<Note> get notes => _notes;

  // Add a note.
  void addNote(Note note) {
    _notes.add(note);
    saveNotes();
  }

  // Remove a note.
  void removeNote(int index) {
    if (index < _notes.length) {
      _notes.removeAt(index);
      saveNotes();
      isNotesDeleted = true;
    }
  }

  // Update a note.
  void updateNote(int index, Note note) {
    _notes[index] = note;
    saveNotes();
  }

  // Initialize the NoteProvider.
  void init() async {
    await loadNotes();
  }

  // Load notes from SharedPreferences.
  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
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

    if ((prefs.getStringList('notes') ?? []).isEmpty && !isNotesDeleted) {
      _notes = List<Note>.generate(
        5,
        (i) => Note(
          title: 'Sample Note ${i + 1}',
          content: 'This is sample note number ${i + 1}.',
          timestamp: DateTime.now(),
        ),
      );
      saveNotes();
    }
  }

  // Save notes to SharedPreferences.
  Future<void> saveNotes() async {
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
}
