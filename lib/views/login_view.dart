import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/utilities/errors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Login Screen'),
          backgroundColor: Colors.amberAccent,
          foregroundColor: Colors.white),
      body: Column(
        children: [
          TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                labelText: 'Email',
              )),
          TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
                labelText: 'Password',
              )),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  notesRoute,
                  (route) => false,
                );
              } on FirebaseAuthException catch (e) {
                if(!context.mounted) return;
                switch (e.code) {
                  case 'invalid-credential':
                    await showErrorDialog(context, 'Invalid credentials, check again');
                    break;
                  case 'invalid-email':
                    await showErrorDialog(context, 'Email Address is invalid!');
                    break;
                  case 'user-not-found':
                    await showErrorDialog(context, 'user does not exist');
                    break;
                  case 'wrong-password':
                    await showErrorDialog(context, 'Wrong Password!');
                    break;
                  default:
                    await showErrorDialog(context, 'Error: ${e.code}');
                }
              } catch (e) {
                await showErrorDialog(context, 'An unexpected error occurred: $e');
              }
            },
            child: const Text('Login'),
          ),
          const Text('Not Registered Yet?'),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Go to Register Screen')),
        ],
      ),
    );
  }
}