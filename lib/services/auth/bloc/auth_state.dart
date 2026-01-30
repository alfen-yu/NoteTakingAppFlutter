import 'package:dartbasics/services/auth/auth_user.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
// constant constructor for states 
abstract class AuthState {
  const AuthState(); 
}

// a state for loading 
class AuthStateLoading extends AuthState {
  const AuthStateLoading(); 
}

// a state for when the user is logged in, extracts from the state, not a global user  
class AuthStateLoggedIn extends AuthState {
  final AuthUser user; 
  const AuthStateLoggedIn(this.user); 
}

// login failures 
// class AuthStateLoginFailure extends AuthState {
//   final Exception exception; 
//   // constructor 
//   const AuthStateLoginFailure(this.exception); 
// }

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification(); 
}

// a state for when the user logs out. doesnt carry anything with itself 
class AuthStateLoggedOut extends AuthState {
  final Exception? exception; // optional exception in the logged out state 
  const AuthStateLoggedOut(this.exception); 
}

// logout failures 
// class AuthStateLogoutFailure extends AuthState {
//   final Exception exception; 
//   // constructor 
//   const AuthStateLogoutFailure(this.exception); 
// } 