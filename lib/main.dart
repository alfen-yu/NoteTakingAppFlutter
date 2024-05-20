import 'package:flutter/material.dart';
import './views/register_view.dart';
import './views/login_view.dart';
// ignore_for_file: avoid_print

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // initializes everything at the start
  runApp(MaterialApp(
    title: 'Flutter Start',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      useMaterial3: true,
    ),
    home: const LoginView(),
  ));
}