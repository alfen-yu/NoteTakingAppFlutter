import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/services/auth/auth_exceptions.dart';
import 'package:dartbasics/services/auth/bloc/auth_bloc.dart';
import 'package:dartbasics/services/auth/bloc/auth_event.dart';
import 'package:dartbasics/services/auth/bloc/auth_state.dart';
import 'package:dartbasics/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is AuthStateLoggedOut) {
                if (state.exception is UserNotFoundAuthException) {
                  await showErrorDialog(context, "User Not Found");
                } else if (state.exception is InvalidCredentialsAuthException) {
                  await showErrorDialog(context, "Invalid Credentials");
                } else if (state.exception is InvalidEmailAuthException) {
                  await showErrorDialog(context, "Invalid Email");
                } else if (state.exception is GenericAuthException) {
                  await showErrorDialog(
                      context, "An error occurred with login");
                }
              }
            },
            child: TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(AuthEventLogIn(email, password));
              },
              child: const Text('Login'),
            ),
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
