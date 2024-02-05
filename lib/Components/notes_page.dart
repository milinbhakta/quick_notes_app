import 'package:flutter/material.dart';
import 'package:quick_notes_app/Util/note_class.dart'; // Import NoteProvider
import 'package:intl/intl.dart';
import 'dart:math' as math;

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _searchQuery = '';
  ValueNotifier<bool> _isHovering = ValueNotifier<bool>(false);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void _showNoteDialog(String dialogTitle, Function(String, String) onSave) {
    if (dialogTitle == 'New Note') {
      _titleController.clear();
      _contentController.clear();
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _NoteDialog(
          dialogTitle: dialogTitle,
          titleController: _titleController,
          contentController: _contentController,
          onSave: onSave,
        );
      },
    );
  }

  void _addNote() {
    _showNoteDialog('New Note', (String title, String content) {
      setState(() {
        NoteProvider.instance.addNote(
            Note(title: title, content: content, timestamp: DateTime.now()));
      });
    });
  }

  void _updateNote(int index) {
    _titleController.text = NoteProvider.instance.notes[index].title;
    _contentController.text = NoteProvider.instance.notes[index].content;

    _showNoteDialog('Update Note', (String title, String content) {
      setState(() {
        NoteProvider.instance.updateNote(index,
            Note(title: title, content: content, timestamp: DateTime.now()));
      });
    });
  }

  void _deleteNote(int index) {
    setState(() {
      NoteProvider.instance.removeNote(index);
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
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                filled: true,
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
                return _buildNotesList();
              }
            },
          )),
        ],
      ),
      floatingActionButton: MouseRegion(
        onEnter: (_) {
          _isHovering.value = true;
          _controller.forward();
        },
        onExit: (_) {
          _isHovering.value = false;
          _controller.reverse();
        },
        child: FloatingActionButton(
          onPressed: _addNote,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Transform.rotate(
                angle: _controller.value * math.pi,
                child: child,
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    List<Note> notes = _searchQuery.isEmpty
        ? NoteProvider.instance.notes
        : NoteProvider.instance.notes.where((note) {
            return note.title
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                note.content.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
                title: Text(notes[index].title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(notes[index].content),
                    Text(
                      'Last updated: ${DateFormat('yyyy-MM-dd – kk:mm').format(notes[index].timestamp)}',
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 10),
                    ),
                  ],
                ),
                trailing: _searchQuery.isEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _updateNote(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteNote(index),
                          ),
                        ],
                      )
                    : null));
      },
    );
  }
}

class _NoteDialog extends StatelessWidget {
  final String dialogTitle;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final Function(String, String) onSave;

  const _NoteDialog({
    required this.dialogTitle,
    required this.titleController,
    required this.contentController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(hintText: 'Content'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton.tonal(
          child: const Text('Save'),
          onPressed: () {
            String title = titleController.text;
            String content = contentController.text;
            titleController.clear();
            contentController.clear();
            onSave(title, content);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
