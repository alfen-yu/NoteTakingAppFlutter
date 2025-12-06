import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/views/login_view.dart';
import 'package:dartbasics/views/notes/cru_note_view.dart';
import 'package:dartbasics/views/notes/notes_view.dart';
import 'package:dartbasics/views/register_view.dart';
import 'package:dartbasics/views/verify_email_view.dart';
import 'package:flutter/material.dart';
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Initializes everything at the start
  
  // Initialize Firebase before running the app
  await AuthService.firebase().initialize();

  runApp(MaterialApp(
    title: 'Notes App',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmail: (context) => const VerifyEmailView(),
      cruNoteRoute: (context) => const CRUNoteView(), // create, read, or update note route
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;
    if (user != null) {
      if (user.isEmailVerified) {
        return const NotesView();
      } else {
        return const VerifyEmailView();
      }
    } else {
      return const LoginView();
    }
  }
}

// basic state of our bloc 
@immutable 
abstract class CounterState {
  final int value; 
  const CounterState(this.value);
}

// inherited from counterstate, checks for a valid/invalid state of value 
class CounterStateValid extends CounterState {
  const CounterStateValid(super.value);
}

class CounterStateInvalid extends CounterState {
  final String invalidValue; 
  
  const CounterStateInvalid(super.value, {
    required this.invalidValue, 
    required int previousValue,
  });
}

// event in the state for the bloc 
@immutable
abstract class CounterEvent {
  final String value; 
  const CounterEvent(this.value);
}




















// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(title: const Text("Testing bloc")),
//         body: BlocConsumer(builder: builder, listener: listener),
//       ),
//     );
//   }
// }

// @immutable
// abstract class CounterState {
//   final int value;
//   const CounterState(this.value);
// }

// class CounterStateValid extends CounterState {
//   const CounterStateValid(super.value);
// }

// class CounterStateInvalidNumber extends CounterState {
//   final String invalidValue;
//   const CounterStateInvalidNumber({
//     required this.invalidValue,
//     required int previousValue,
//   }) : super(previousValue);
// }

// @immutable
// abstract class CounterEvent {
//   final String value;
//   const CounterEvent(this.value);
// }

// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(super.value);
// }

// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(super.value);
// }

// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);

//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//             invalidValue: event.value, previousValue: state.value));
//       } else {
//         emit(CounterStateValid(state.value + integer));
//       }
//     });
//     on<DecrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);

//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//             invalidValue: event.value, previousValue: state.value));
//       } else {
//         emit(CounterStateValid(state.value - integer));
//       }
//     });
//   }
// }
