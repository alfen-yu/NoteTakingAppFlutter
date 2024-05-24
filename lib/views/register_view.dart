import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/utilities/errors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      appBar: AppBar(
        title: const Text('Register Screen'),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.orangeAccent,
      ),
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
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email, password: password);
                final user = FirebaseAuth.instance.currentUser;
                user?.sendEmailVerification();
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(
                  verifyEmail,
                );
              } on FirebaseAuthException catch (e) {
                if (!context.mounted) return;
                switch (e.code) {
                  case 'email-already-in-use':
                    await showErrorDialog(
                        context, 'Email account already in use.');
                    break;
                  case 'invalid-email':
                    await showErrorDialog(
                        context, 'Your email address is invalid!');
                    break;
                  case 'weak-password':
                    await showErrorDialog(
                        context, 'Please enter a strong password!');
                    break;
                  default:
                    await showErrorDialog(context, 'Error: ${e.code}');
                }
              } catch (e) {
                await showErrorDialog(
                    context, 'An unexpected error occurred: $e');
              }
            },
            child: const Text('Register'),
          ),
          const Text('Already Registered?'),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Login Here')),
        ],
      ),
    );
  }
}
