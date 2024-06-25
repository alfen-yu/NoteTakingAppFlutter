import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/enums/menu_action.dart';
import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/services/cloud/cloud_note.dart';
import 'package:dartbasics/services/cloud/firebase_cloud_storage.dart';
import 'package:dartbasics/utilities/dialogs/generic_dialog.dart';
import 'package:dartbasics/views/notes/notes_list_view.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get uid => AuthService.firebase().currentUser!.id;
  int _selectedIndex = 0;

  @override
  // we want to have a notes service in our init state
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // You can add navigation logic here if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: const Color.fromARGB(255, 67, 196, 166),
        foregroundColor: const Color.fromARGB(255, 117, 32, 2),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(cruNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final logoutResult = await showGenericDialog(
                      context: context,
                      title: 'Logout?',
                      content: 'Are you sure you want to logout?',
                      optionsBuilder: () => {'OK': true, 'Cancel': false});
                  if (logoutResult) {
                    await AuthService.firebase().logout();
                    if (!context.mounted) return;
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                default:
                  devtools.log(
                      'nothing is going to happen, dont worry, you should be happy :3)');
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
                stream: _notesService.allNotes(ownerUserId: uid),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as Iterable<CloudNote>;
                        return NotesListView(
                            notes: allNotes,
                            onDeleteNote: (note) async {
                              await _notesService.deleteNote(documentId: note.documentId);
                            },
                            onTapNote: (note) {
                              Navigator.of(context).pushNamed(cruNoteRoute, arguments: note);
                            },
                            );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_task),
            label: 'Post a Task',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
