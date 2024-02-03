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

  // List of filtered notes.
  List<Note> _filteredNotes = [];

  // Getter for notes.
  List<Note> get notes => _notes;

  // Add a note.
  void addNote(Note note) {
    _notes.add(note);
    saveNotes();
  }

  // Remove a note.
  void removeNote(int index) {
    _notes.removeAt(index);
    saveNotes();
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

  // filter notes
  List<Note> filterNotes(String query) {
    _filteredNotes = _notes
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _filteredNotes;
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

    if (_notes.isEmpty) {
      for (int i = 1; i <= 15; i++) {
        addNote(
          Note(
            title: 'Sample Note $i',
            content: 'This is sample note number $i.',
            timestamp: DateTime.now(),
          ),
        );
      }
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
