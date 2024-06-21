import 'package:dartbasics/services/crud/notes_service.dart';
import 'package:dartbasics/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

typedef NoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTapNote; 

  const NotesListView(
      {super.key, required this.notes, required this.onDeleteNote, required this.onTapNote});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          onTap: () => {onTapNote(note)},
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final deleteResult = await showGenericDialog(
                context: context,
                title: 'Delete Note?',
                content: 'Do you want to delete this note?',
                optionsBuilder: () => {'OK': true, 'Cancel': false},
              );
              if (deleteResult == true) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
