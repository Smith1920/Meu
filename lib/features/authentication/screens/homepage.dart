// ignore_for_file: use_build_context_synchronously

import 'package:chapal/features/authentication/cubit/auth_cubit.dart';
import 'package:chapal/features/authentication/cubit/auth_state.dart';
import 'package:chapal/features/authentication/cubit/message_cubit.dart';
import 'package:chapal/features/authentication/screens/chat_screen.dart';
import 'package:chapal/features/authentication/screens/register_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>>? lstUser = [];
  Map<String, dynamic>? lastMsg = {};
  AuthenticationCubit? _authCubit;
  MessageCubit? _userCubit;

  FirebaseAuth current = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    _userCubit = BlocProvider.of<MessageCubit>(context);
    _authCubit = BlocProvider.of<AuthenticationCubit>(context);
    getAllUsers();
    firestore
        .collection('users')
        .doc(current.currentUser!.uid)
        .snapshots()
        .listen((event) {
      //last();
      _userCubit?.refresh();
    });

    super.initState();
  }

  void getAllUsers() async {
    lstUser = await _userCubit?.getAllUsers();
  }

  // void last() async {
  //   lastMsg = await _userCubit?.getLastMsg();
  // }

  Widget getList() {
    return ListView.builder(
      itemCount: lstUser?.length,
      itemBuilder: (context, index) {
        print(lastMsg?['date']);
        return lstUser?[index]['uid'] == current.currentUser?.uid
            ? const SizedBox(
                height: 1,
              )
            : InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(userData: lstUser?[index]),
                    ),
                  );
                },
                child: Card(
                  child: ListTile(
                    title: Text(
                      lstUser?[index]['name'],
                    ),
                    subtitle: Text(
                      lstUser?[index]['message'] ?? 'No Data',
                    ),
                    trailing: lstUser?[index]['date'] != null
                        ? Text(lstUser?[index]['date'])
                        : const Text('No Data'),
                  ),
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: () async {
              if (await _authCubit?.logout() == true) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => RegisterLogin(),
                  ),
                );
                Fluttertoast.showToast(msg: 'Successfully Logged Out.');
              } else {
                Fluttertoast.showToast(msg: 'Something Went Wrong.');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<MessageCubit, AuthenticationState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is AuthenticationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AuthenticationSuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                Future.delayed(
                  const Duration(seconds: 1),
                );
                lstUser = await _userCubit?.getAllUsers();
                getList();
              },
              child: getList(),
            );
          } else {
            return Container(
              height: 10,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            );
          }
        },
      ),
    );
  }
}
