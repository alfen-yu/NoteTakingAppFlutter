// login exceptions 
class UserNotFoundAuthException implements Exception {}
class WrongPasswordAuthException implements Exception {}
class InvalidCredentialsAuthException implements Exception {}

// register exceptions 
class EmailAlreadyInUseAuthException implements Exception {}
class WeakPasswordAuthException implements Exception {}

// generic excpetions  
class InvalidEmailAuthException implements Exception {}
class GenericAuthException implements Exception {}
class UserNotLoggedInException implements Exception {}