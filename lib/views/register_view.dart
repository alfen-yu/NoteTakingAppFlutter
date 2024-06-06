import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/services/auth/auth_exceptions.dart';
import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/utilities/errors.dart';
import 'package:flutter/material.dart';

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
                await AuthService.firebase()
                    .createUser(email: email, password: password);
                AuthService.firebase().sendEmailVerification();
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(
                  verifyEmail,
                );
              }
              // using the auth services
              on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, 'Email account already in use.');
              } on InvalidEmailAuthException {
                await showErrorDialog(
                    context, 'Your email address is invalid!');
              } on WeakPasswordAuthException {
                await showErrorDialog(
                    context, 'Please enter a strong password!');
              } on GenericAuthException {
                await showErrorDialog(context, 'An unexpected error occurred.');
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
