import 'package:chapal/features/authentication/cubit/auth_cubit.dart';
import 'package:chapal/features/authentication/cubit/auth_state.dart';
import 'package:chapal/features/authentication/cubit/chat_cubit.dart';
import 'package:chapal/features/authentication/cubit/chat_state.dart';
import 'package:chapal/features/authentication/cubit/message_cubit.dart';
import 'package:chapal/features/authentication/screens/homepage.dart';
import 'package:chapal/features/authentication/screens/register_login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthenticationCubit(
            AuthenticationInitial(),
          ),
        ),
        BlocProvider(
          create: (context) => MessageCubit(
            AuthenticationInitial(),
          ),
        ),
        BlocProvider(
          create: (context) => ChatCubit(
           ChatInitial(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chapal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthenticationCubit? _auth;
  bool? isLogin;

  @override
  void initState() {
    _auth = BlocProvider.of<AuthenticationCubit>(context);
    getStatus();
    super.initState();
  }

  Future<void> getStatus() async {
    isLogin = await _auth?.loadToken();
    Fluttertoast.showToast(msg: "$isLogin");
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoggedIn) {
          if (state.status == true) {
            return HomePage();
          } else {
            return RegisterLogin();
          }
        } else {
          return RegisterLogin();
        }
      },
    );
  }
}
