import 'package:dartbasics/firebase_options.dart';
import 'package:dartbasics/views/login_view.dart';
import 'package:dartbasics/views/register_view.dart';
import 'package:dartbasics/views/verify_email_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
// ignore_for_file: avoid_print

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Initializes everything at the start

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    title: 'Flutter Start',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      '/login': (context) => const LoginView(),
      '/register': (context) => const RegisterView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (user.emailVerified) {
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

// pop up menu items enum
enum MenuAction {
  settings,
  logout,
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('My Notes'),
            backgroundColor: const Color.fromARGB(255, 67, 196, 166),
            foregroundColor: const Color.fromARGB(255, 117, 32, 2),
            actions: [
          ElevatedButton(onPressed: () {}, child: const Text('Logout')),
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final logoutResult = await showLogoutDialog(context);
                if (logoutResult) {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (_) => false);
                }
              default:
                devtools.log(
                    'nothing is going to happen, dont worry, you should be happy ::3)');
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, child: Text('Logout'))
            ];
          }),
        ]));
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
