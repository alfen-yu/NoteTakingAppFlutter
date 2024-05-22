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
      appBar: AppBar(title: const Text('Login Screen'), backgroundColor: Colors.amberAccent, foregroundColor: Colors.white),
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
                final userCredentials = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(email: email, password: password);
                print(userCredentials);
              } on FirebaseAuthException catch (e) {
                switch (e.code) {
                  case 'invalid-credential':
                    print('Invalid credentials, check again');
                    break;
                  case 'invalid-email':
                    print('Email address is invalid');
                    break;
                  case 'user-not-found':
                    print('User does not exist');
                    break;
                  case 'wrong-password':
                    print('Wrong password');
                    break;
                  default:
                    print('something veri bad happened sori');
                }
              } catch (e) {
                print('An unexpected error occurred: $e');
              }
            },
            child: const Text('Login'),
          ),
          const Text('Not Registered Yet?'),
          TextButton(onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/register', (route) => false);
          }, child: const Text('Go to Register Screen')),
        ],
      ),
    );
  }
}
