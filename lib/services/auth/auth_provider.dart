import 'package:dartbasics/services/auth/auth_user.dart';

// abstract class inmplemented by firebase auth provider, auth service
// can also be implemented for other authentication services

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> login({required String email, required String password});
  Future<AuthUser> createUser({required String email, required String password});
  Future<void> logout();
  Future<void> sendEmailVerification();
}