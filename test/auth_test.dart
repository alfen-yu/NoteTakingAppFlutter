import 'package:dartbasics/services/auth/auth_exceptions.dart';
import 'package:dartbasics/services/auth/auth_provider.dart';
import 'package:dartbasics/services/auth/auth_user.dart';
import 'package:test/test.dart';

// mock function tests the functionality of a function like a spy, we implement all the functionalities that the original function implements but with special logic which
// overrides our original function

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false); // the flag should be false when started 
    });

    // logout test 
    // a user should exist and logged in otherwise this test can check if the user is not logged in 
    test('Cannot logout if not initialized', () {
      expect(() => provider.logout(), throwsA(const TypeMatcher<NotInitializedException>()), // expects an exception
      );
    });

    // init function, test user should be initialized isInitialize flag should be true 
    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    // if it takes more time than necessary this test checks that 
    test('Test should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    // test: creation of a user 
    test('Create User should delegate to login function', () async {
      // checks for the bad email
      expect(() => provider.createUser(email: 'foo@bar.com', password: 'anypassword'), throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      // check for the bad password
      expect(() => provider.createUser(email: 'someone@bar.com', password: 'foobar'), throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      // checks for correct creation
      final user = await provider.createUser(email: 'foo', password: 'bar');
      expect(provider.currentUser, user);

      expect(user.isEmailVerified, false);
    });

    // email verification test
    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true); // forcefully unwrapped
    });

    // logout test
    test('Should be able to logout and login again', () async {
      await provider.logout(); // logouts first then logs in 
      await provider.login(email: 'email', password: 'password');

      final user = provider.currentUser; // checks if the user is able to login again 
      expect(user, isNotNull); // user shouldn't be null if it has logged in again 
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user; // a null user, private variable

  var _isInitialized = false; // private property

  bool get isInitialized => _isInitialized; // getter function for initialized

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user; // returns the user

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(id: 'my-id' ,isEmailVerified: false, email: '');
    _user = user; 
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(id: 'my-id' , isEmailVerified: true, email: '');
    _user = newUser;
  }
}