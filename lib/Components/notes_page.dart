import 'package:flutter/material.dart';
import 'package:quick_notes_app/Util/note_class.dart'; // Import NoteProvider
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _searchQuery = '';
  List<Note> _filteredNotes = [];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeNotes();
  }

  void _initializeNotes() async {
    await NoteProvider.instance.loadNotes();
    setState(() {
      _filteredNotes = NoteProvider.instance.notes;
    });
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
      _filteredNotes = NoteProvider.instance.filterNotes(_searchQuery);
    });
  }

  void _showNoteDialog(String title, Function(String, String) onSave) {
    if (title == 'New Note') {
      _titleController.clear();
      _contentController.clear();
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
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
                ElevatedButton(
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
        NoteProvider.instance.addNote(Note(
            title: title,
            content: content,
            timestamp: DateTime.now())); 
      });
    });
  }

  void _updateNote(int index) {
    _titleController.text = NoteProvider
        .instance.notes[index].title; // Use NoteProvider to get note
    _contentController.text = NoteProvider
        .instance.notes[index].content; // Use NoteProvider to get note

    _showNoteDialog('Update Note', (String title, String content) {
      setState(() {
        NoteProvider.instance.updateNote(
            index,
            Note(
                title: title,
                content: content,
                timestamp: DateTime.now())); // Use NoteProvider to update note
      });
    });
  }

  void _deleteNote(int index) {
    setState(() {
      NoteProvider.instance
          .removeNote(index); // Use NoteProvider to delete note
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: const InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
              child: FutureBuilder(
            future: NoteProvider.instance.loadNotes(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return ListView.builder(
                  itemCount: _filteredNotes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_filteredNotes[index].title),
                      subtitle: Text(_filteredNotes[index].content),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              'Last updated: ${DateFormat('yyyy-MM-dd – kk:mm').format(_filteredNotes[index].timestamp)}',
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
                );
              }
            },
          )),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 48.0,
        width: 48.0,
        child: FloatingActionButton(
          onPressed: _addNote,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
