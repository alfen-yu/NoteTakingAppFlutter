import 'package:dartbasics/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore_for_file: avoid_print

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // initializes everything at the start

  runApp(MaterialApp(
    title: 'Flutter Start',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      useMaterial3: true,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.white,
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                // /  !(user?.emailVerified ?? false)
                //   user?.emailVerified: Safely accesses the emailVerified property. If user is null, this expression evaluates to null.
                // / ?? false: Provides a default value of false if the preceding expression is null.
                // / !(...): Negates the result to check if the email is not verified.

                if (user != null && !user.emailVerified) {
                  print('Email not verified');
                } else {
                  print('User is verified.');
                }

                return const Text('Done');
              default:
                return const Text('Loading....');
            }
          },
        ));
  }
}