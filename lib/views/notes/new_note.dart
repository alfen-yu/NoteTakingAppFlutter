import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {

  // PRIVATE VARIABLES AND FUNCTIONS DEFINED HERE 

  DatabaseNote? _note; // optional private variable for the new note
  late final NotesService _notesService;

  // a text field that will vertically expand and shrink, also keep track of the text user enters and synced with firebase and database. 
  late final TextEditingController _textController; 

  @override 
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }


  // delete note if text is empty and user returns to the notes screen 
  void _deleteEmptyNote() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  // save a note if text has changed and it is not empty 
  void _saveNote() async {
    final note = _note; 
    final text = _textController.text;

    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(note: note, text: text);
    }
  }


  // whenever the text changes, this function is called
  void _textControllerListener() async {
    final note = _note;

    if (note == null) {
      return;
    } else {
      final text = _textController.text;
      await _notesService.updateNote(note: note, text: text);
    }
  }

  // removes the textControllerListener and adds it again 
  // setup of the text controller listener
  void _setupListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  // PRIVATE VARIABLES AND FUNCTIONS END 

  // checks if the note already exists otherwise create the note 
  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note; 
    if (existingNote != null) {
      return existingNote;
    } 

    // create note function takes a user (owner) therefore, we need to define a user and its email first 
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
    }


  // cleaning function 
  @override 
  void dispose() {
    _deleteEmptyNote();
    _saveNote();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a Note'),),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setupListener(); // starts listening for user text changes 
              return TextField(
                // our text field will expand if text increases 
                controller: _textController, 
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Start typing your text...'),
                ); // checks for changes in the text field 
            default:
              return const CircularProgressIndicator();
          }
        }
        ),
    );
  }
}