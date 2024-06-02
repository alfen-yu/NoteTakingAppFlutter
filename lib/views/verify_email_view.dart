import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/services/auth_service.dart';
import 'package:flutter/material.dart';

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
              await AuthService.firebase().sendEmailVerification(); // auth service function 
            },
            child: const Text('Send Email verification'),
          ),
          const Text("If you have already verified your email, you can proceed to login."),
          TextButton(onPressed: () async {
            await AuthService.firebase().logout(); // auth service function 
            if(!context.mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
          }, child: const Text('Go to Login View')),
        ],
      ),
    );
  }
}
