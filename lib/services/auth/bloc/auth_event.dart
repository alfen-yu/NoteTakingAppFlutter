import 'package:flutter/foundation.dart' show immutable;

// abstract class for events 
@immutable
abstract class AuthEvent {
  const AuthEvent(); 
}

// initialization of firebase, database, anything 
class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize(); 
}

// login event 
class AuthEventLogIn extends AuthEvent {
  final String email; 
  final String password; 
  const AuthEventLogIn(this.email, this.password); 
}

// logout event 
class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut(); 
}