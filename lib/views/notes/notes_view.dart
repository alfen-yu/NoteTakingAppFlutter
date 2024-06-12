import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/enums/menu_action.dart';
import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/services/crud/notes_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  // we want to have a notes service in our init state
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Notes App'),
          backgroundColor: const Color.fromARGB(255, 67, 196, 166),
          foregroundColor: const Color.fromARGB(255, 117, 32, 2),
          actions: [
            IconButton(onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            }, icon: const Icon(Icons.add)),
            PopupMenuButton<MenuAction>(onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final logoutResult = await showLogoutDialog(context);
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
            }, itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text('Logout'))
              ];
            }),
          ]),
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
                        return const Text('Waiting for all notes...');
                      default:
                        return const CircularProgressIndicator();
                    }
                  });
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
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                Navigator.of(context).pop(true);
              },
              child: const Text('Logout')),
        ],
      );
    },
  ).then((value) => value ?? false);
}
