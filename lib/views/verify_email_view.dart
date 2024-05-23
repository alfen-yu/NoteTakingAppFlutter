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
          const Text('Please Verify your email address'),
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
        ],
      ),
    );
  }
}