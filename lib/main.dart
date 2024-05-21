import 'package:dartbasics/firebase_options.dart';
import 'package:dartbasics/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
                return const Text('Loading....');
            }
          }),
    );
  }
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Please Verify your email address'),
        TextButton(
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            print(user);
            if (user?.emailVerified == true) {
              print('The email is now verified');
            } else { 
              print('not verified');
            }
            await user?.sendEmailVerification();
          },
          child: const Text('Send Email verification'),
        ),
      ],
    );
  }
}
