import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/views/login_view.dart';
import 'package:dartbasics/views/notes/cru_note_view.dart';
import 'package:dartbasics/views/notes/notes_view.dart';
import 'package:dartbasics/views/register_view.dart';
import 'package:dartbasics/views/verify_email_view.dart';
import 'package:flutter/material.dart';
// ignore_for_file: avoid_print

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Initializes everything at the start

  runApp(MaterialApp(
    title: 'Notes App',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmail: (context) => const VerifyEmailView(),
      cruNoteRoute: (context) => const CRUNoteView(), // create, read, or update note route 
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
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