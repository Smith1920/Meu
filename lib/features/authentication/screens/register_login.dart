import 'package:chapal/features/authentication/cubit/auth_cubit.dart';
import 'package:chapal/features/authentication/cubit/auth_state.dart';
import 'package:chapal/features/authentication/modal/user_modal.dart';
import 'package:chapal/features/authentication/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterLogin extends StatefulWidget {
  RegisterLogin({super.key});

  @override
  State<RegisterLogin> createState() => _RegisterLoginState();
}

class _RegisterLoginState extends State<RegisterLogin> {
  String name = '', email = '', user = '', password = '';
  bool variable = false;
  UserModal? userData;

  AuthenticationCubit? _authCubit;

  @override
  void initState() {
    _authCubit = BlocProvider.of<AuthenticationCubit>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Center(
            child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
              listener: (context, state) {
                if (state is AuthenticationSuccess) {
                  if (userData?.uid == null) {
                    Fluttertoast.showToast(msg: 'Please check credentials.');
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                    _authCubit?.savingToken(userData?.uid);
                    variable = !variable;
                  }
                } else if (state is LoginRegister) {
                  variable = state.isLogin;
                }
              },
              builder: (context, state) {
                if (state is AuthenticationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is AuthenticationSuccess) {
                } else if (state is AuthenticationError) {
                  Fluttertoast.showToast(msg: 'Something went wrong..');
                }
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: variable,
                        child: TextField(
                          decoration: const InputDecoration(
                            label: Text('Name'),
                            hintText: 'Your Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            name = value;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Visibility(
                        visible: variable,
                        child: TextField(
                          decoration: const InputDecoration(
                            label: Text('Username'),
                            hintText: 'Nickname',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            user = value;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          label: Text('Email'),
                          hintText: 'Personal Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          email = value;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          label: Text('Password'),
                          hintText: 'Atleast 6 digits.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (variable == false) {
                                  if (email.isNotEmpty && password.isNotEmpty) {
                                    userData = await _authCubit?.loginuser(
                                        email, password);
                                    print("Name: ${userData?.name}");
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Please Check Fields.');
                                  }
                                } else {
                                  if (email.isNotEmpty &&
                                      password.isNotEmpty &&
                                      name.isNotEmpty &&
                                      user.isNotEmpty) {
                                    _authCubit?.registerUser(
                                        email, name, user, password);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Please Check Fields.');
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 80),
                                child:
                                    Text(variable == true ? 'Register' : 'Login'),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextButton(
                          onPressed: () {
                            _authCubit?.getStatus(variable);
                          },
                          child: Text(variable == true ? 'Login' : 'Signup'))
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
