import 'package:dartbasics/constants/routes.dart';
import 'package:dartbasics/services/auth/auth_service.dart';
import 'package:dartbasics/services/auth/bloc/auth_bloc.dart';
import 'package:dartbasics/services/auth/bloc/auth_event.dart';
import 'package:dartbasics/services/auth/bloc/auth_state.dart';
import 'package:dartbasics/services/auth/firebase_auth_provider.dart';
import 'package:dartbasics/views/login_view.dart';
import 'package:dartbasics/views/notes/cru_note_view.dart';
import 'package:dartbasics/views/notes/notes_view.dart';
import 'package:dartbasics/views/register_view.dart';
import 'package:dartbasics/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore_for_file: avoid_print

// 1:02:58:42

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
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmail: (context) => const VerifyEmailView(),
      cruNoteRoute: (context) =>
          const CRUNoteView(), // create, read, or update note route
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//         create: (context) => CounterBloc(),
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('testing bloc'),
//           ),
//           body: BlocConsumer<CounterBloc, CounterState>(
//               builder: (context, state) {
//             final invalidValue =
//                 (state is CounterStateInvalid ? state.invalidValue : '');
//             return Column(
//               children: [
//                 Text('Current Value => ${state.value}'),
//                 Visibility(
//                     visible: (state is CounterStateInvalid),
//                     child: Text('Invalid Input: $invalidValue')),
//                 TextField(
//                   controller: _controller,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter a number here',
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 Row(
//                   children: [
//                     TextButton(
//                         onPressed: () {
//                           context
//                               .read<CounterBloc>()
//                               .add(DecrementEvent(_controller.text));
//                         },
//                         child: const Text('-')),
//                     TextButton(
//                         onPressed: () {
//                           context
//                               .read<CounterBloc>()
//                               .add(IncrementEvent(_controller.text));
//                         },
//                         child: const Text('+')),
//                   ],
//                 )
//               ],
//             );
//           }, listener: (context, state) {
//             _controller.clear();
//           }),
//         ));
//   }

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
// }

// // basic state of our bloc
// @immutable
// abstract class CounterState {
//   final int value;
//   const CounterState(this.value);
// }

// // inherited from counterstate, checks for a valid/invalid state of value
// class CounterStateValid extends CounterState {
//   const CounterStateValid(super.value);
// }

// class CounterStateInvalid extends CounterState {
//   final String invalidValue;

//   const CounterStateInvalid(
//     super.value, {
//     required this.invalidValue,
//   });
// }

// // event in the state for the bloc
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

// // Bloc of the Counter
// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInvalid(
//           state.value,
//           invalidValue: event.value,
//         ));
//       } else {
//         emit(CounterStateValid(state.value + integer));
//       }
//     });

//     on<DecrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInvalid(
//           state.value,
//           invalidValue: event.value,
//         ));
//       } else {
//         emit(CounterStateValid(state.value - integer));
//       }
//     });
//   }
// }
