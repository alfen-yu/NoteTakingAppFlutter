import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/enums/menu_action.dart';
import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/services/crud/notes_service.dart';
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
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email;
  int _selectedIndex = 0;

  @override
  // we want to have a notes service in our init state
  void initState() {
    _notesService = NotesService();
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
      body: FutureBuilder(
        // the future builder checks for the user if it exists, then a stream of all notes is returned if a user is there
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                            notes: allNotes,
                            onDeleteNote: (note) async {
                              await _notesService.deleteNote(id: note.id);
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
              );
            case ConnectionState.none:
              return const Text('None');
            case ConnectionState.waiting:
              return const Text('Waiting');
            case ConnectionState.active:
              return const Text('Active');
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
