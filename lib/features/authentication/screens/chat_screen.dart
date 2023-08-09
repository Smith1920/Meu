import 'dart:async';

import 'package:chapal/features/authentication/cubit/chat_cubit.dart';
import 'package:chapal/features/authentication/cubit/chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key, required this.userData});
  Map<String, dynamic>? userData;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var txt = TextEditingController();
  ScrollController scroll = ScrollController();
  String val = '';
  String save = '';
  ScrollController controller = ScrollController();
  bool isRev = false, isLoad = false;
  Map<String, dynamic> lastMsg = {};

  String id = FirebaseAuth.instance.currentUser!.uid;

  ChatCubit? chatCubit;
  List<Map<String, dynamic>>? lstUser = [];

  @override
  void initState() {
    chatCubit = BlocProvider.of<ChatCubit>(context);
    getmsg();
    isLoad = true;
    super.initState();
    print("Start-----------------");
    _firestore
        .collection('chats')
        .doc("${id}_${widget.userData?['uid']}")
        .collection('messages')
        .orderBy('date', descending: false)
        .snapshots()
        .listen((event) {
      print("Length of chats: ${lstUser?.length}");
      print(event.docs.last.data().toString());
      lstUser = lstUser?.reversed.toList();
      lastMsg = event.docs.last.data();
      lstUser?.add(event.docs.last.data());
      lstUser = lstUser?.reversed.toList();

      chatCubit?.setupListener();
    });

    _firestore
        .collection('chats')
        .doc("${widget.userData?['uid']}_$id")
        .collection('messages')
        .orderBy('date', descending: false)
        .snapshots()
        .listen((event) {
      print("Length of chats: ${lstUser?.length}");
      print(event.docs.last.data().toString());
      lstUser = lstUser?.reversed.toList();
      lastMsg = event.docs.last.data();
      lstUser?.add(event.docs.last.data());
      lstUser = lstUser?.reversed.toList();
      chatCubit?.setupListener();
    });
    print("End------------------");
  }

  void getmsg() async {
    lstUser?.clear();
    lstUser = await chatCubit?.getMsg(
        FirebaseAuth.instance.currentUser!.uid, widget.userData?['uid']);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          widget.userData?['name'] ?? FirebaseAuth.instance.currentUser?.email,
        ),
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatUpdate) {}
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ChatSuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                lstUser?.clear();
                getmsg();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: ListView.builder(
                  reverse: true,
                  scrollDirection: Axis.vertical,
                  controller: controller,
                  itemCount: lstUser?.length,
                  itemBuilder: (context, index) {
                    if (lstUser?[index]['sentBy'] == id) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Card(
                            elevation: 6,
                            shape: const OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            color: Colors.amber,
                            margin: const EdgeInsets.only(
                                left: 80, right: 0, top: 4, bottom: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                lstUser?[index]['message'],
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('hh:mm a').format(
                              (lstUser?[index]['date'] as Timestamp).toDate(),
                            ),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color.fromARGB(255, 101, 101, 101),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 6,
                            shape: const OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            color: Colors.blue,
                            margin: const EdgeInsets.only(
                                left: 0, right: 80, top: 4, bottom: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                lstUser?[index]['message'],
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('hh:mm a').format(
                              (lstUser?[index]['date'] as Timestamp).toDate(),
                            ),
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      );
                    }
                  },
                ),
              ),
            );
          } else if (state is ChatError) {
            return const Center(
              child: Text('No data'),
            );
          } else {
            return const Center(
              child: Text('Please Wait!'),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                controller: txt,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type Something!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onChanged: (value) {
                  val = value;
                },
              ),
            ),
            IconButton(
              onPressed: () async {
                if (val.isEmpty || val == '') {
                  Fluttertoast.showToast(msg: 'Please Check Message.');
                } else {
                  await chatCubit?.sendMessage(
                      id, widget.userData?['uid'], val, isLoad);
                  save = val;
                  lastMsg = {
                    'sentBy': id,
                    'sentTo': widget.userData?['uid'],
                    'message': val,
                    'date': DateTime.now(),
                  };

                  

                  val = '';
                  txt.clear();
                }
                Timer(
                    const Duration(milliseconds: 100),
                    () =>
                        controller.jumpTo(controller.position.minScrollExtent));
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
