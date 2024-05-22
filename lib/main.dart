import 'package:dartbasics/firebase_options.dart';
import 'package:dartbasics/views/login_view.dart';
import 'package:dartbasics/views/register_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore_for_project: avoid_print

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
                // final user = FirebaseAuth.instance.currentUser;
                // if (user?.emailVerified ?? false) {
                //   print('User is verified.');
                //   return const Text('Done');
                // } else {
                //   print('Email not verified');
                //   print(user);
                //   return const VerifyEmailView();
                // }
                return const LoginView();
              default:
                return const CircularProgressIndicator();
            }
          });
  }
}