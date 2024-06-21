import 'package:flutter/material.dart' show ModalRoute, BuildContext;

// we are gonna return any type that you ask us to, the generic type is T?
extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);

    // protection against null 
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments; // modal route brings us the arguments from the context 
      if (args != null && args is T) {
        return args as T; // if we could grab any args from modal route of the type we want, then return those arguments  
      }
    }
    return null;
  }
}