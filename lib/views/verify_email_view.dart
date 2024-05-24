import 'package:dartbasics/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Verification')),
      body: Column(
        children: [
          const Text("We've sent you an email verification. Please verify your email."),
          const Text("If you haven't received a verification email, press the button below."),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              devtools.log(user.toString());
              if (user?.emailVerified == true) {
                devtools.log('The email is now verified');
              } else {
                devtools.log('not verified');
              }
              await user?.sendEmailVerification();
            },
            child: const Text('Send Email verification'),
          ),
          TextButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if(!context.mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          }, child: const Text('Restart')),
        ],
      ),
    );
  }
}
