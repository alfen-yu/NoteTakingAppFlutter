import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';
import 'package:dartbasics/services/cloud/firebase_cloud_storage.dart';
import 'package:dartbasics/services/cloud/cloud_note.dart';

// CU stands for Create, Read, & Update
class CRUNoteView extends StatefulWidget {
  const CRUNoteView({super.key});

  @override
  State<CRUNoteView> createState() => _CRUNoteViewState();
}

class _CRUNoteViewState extends State<CRUNoteView> {

  // PRIVATE VARIABLES AND FUNCTIONS DEFINED HERE 

  CloudNote? _note; // optional private variable for the new note
  late final FirebaseCloudStorage _notesService;

  // a text field that will vertically expand and shrink, also keep track of the text user enters and synced with firebase and database. 
  late final TextEditingController _textController; 

  @override 
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }


  // delete note if text is empty and user returns to the notes screen 
  void _deleteEmptyNote() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  // save a note if text has changed and it is not empty 
  void _saveNote() async {
    final note = _note; 
    final text = _textController.text;

    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(documentId: note.documentId, text: text);
    }
  }


  // whenever the text changes, this function is called
  void _textControllerListener() async {
    final note = _note;

    if (note == null) {
      return;
    } else {
      final text = _textController.text;
      await _notesService.updateNote(documentId: note.documentId, text: text);
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
  Future<CloudNote> createReadUpdateNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>(); // need to indicate which argument type we want to extract 
    if (widgetNote != null) { // it checks if the widgetnote already has something written in it if it has then it sets our text field to the existing note 
      _note = widgetNote; // we saved it to our note 
      // text field should be pre populated with the existing text 
      _textController.text = widgetNote.text; // giving the already written text to the text controller field 
      return widgetNote; 
    }

    final existingNote = _note; 
    if (existingNote != null) {
      return existingNote;
    } 

    // create note function takes a user (owner) therefore, we need to define a user and its email first 
    final currentUser = AuthService.firebase().currentUser!;
    final uid = currentUser.id;
    final newNote =  await _notesService.createNewNote(ownerUserId: uid);
    _note = newNote; 
    return newNote; 
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
        future: createReadUpdateNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
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