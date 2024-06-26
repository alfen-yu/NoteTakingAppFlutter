import 'package:dartbasics/services/auth/auth_user.dart';
import 'package:dartbasics/services/auth/auth_provider.dart';
import 'package:dartbasics/services/auth/firebase_auth_provider.dart';

// auth service also implements auth provider, it takes an instance of auth provider as well
// auth service is just the provider itself exposing the functionality we give it
// auth service isnt hardcoded to use firebase auth provider, it takes an auth provider from us and expose it to the outside world

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider); // constructor that takes a provider, {dependency injection}

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider()); // gives the FirebaseAuthProvider to AuthService, which we can use to call functions 

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<AuthUser> createUser({required String email, required String password}) => provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> login({required String email, required String password}) => provider.login(email: email, password: password);

  @override
  Future<void> logout() => provider.logout();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
