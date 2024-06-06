import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/services/auth/auth_exceptions.dart';
import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/utilities/errors.dart';
import 'package:flutter/material.dart';

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
                await AuthService.firebase()
                    .login(email: email, password: password);
                final user = AuthService.firebase().currentUser;
                if (user?.isEmailVerified == true) {
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  if (!context.mounted) return;
                  await showErrorDialog(
                      context, 'Please verify your email first.');
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmail,
                    (route) => false,
                  );
                }
              }
              // using the auth services
              on UserNotFoundAuthException {
                await showErrorDialog(context, 'User does not exist.');
              } on InvalidCredentialsAuthException {
                await showErrorDialog(
                    context, 'Invalid credentials, check again');
              } on InvalidEmailAuthException {
                await showErrorDialog(context, 'Email Address is invalid!');
              } on WrongPasswordAuthException {
                await showErrorDialog(context, 'Wrong Password!');
              } on GenericAuthException {
                await showErrorDialog(context, 'An unexpected error occured.');
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
