import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore_for_file: avoid_print

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register Screen'), backgroundColor: Colors.indigoAccent, foregroundColor: Colors.orangeAccent,),
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
                    .createUserWithEmailAndPassword(
                        email: email, password: password);
                print(userCredentials);
              } on FirebaseAuthException catch (e) {
                switch (e.code) {
                  case 'email-already-in-use':
                    print(
                        'there already exists an account with the given email address');
                    break;
                  case 'invalid-email':
                    print('Email address is invalid');
                    break;
                  case 'weak-password':
                    print('the password is not strong enough');
                    break;
                  default:
                    print('something veri bad happened sori');
                }
              }
            },
            child: const Text('Register'),
          ),
          const Text('Already Registered?'),
          TextButton(onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false) ;
          }, child: const Text('Login Here')),
        ],
      ),
    );
  }
}
