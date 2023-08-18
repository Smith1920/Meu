// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chapal/features/authentication/cubit/chat_cubit.dart';
import 'package:chapal/features/authentication/repository/data_secure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserChatScreen extends StatefulWidget {
  UserChatScreen({super.key, required this.lstUser});
  List<Map<String, dynamic>>? lstUser;

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final _auth = FirebaseAuth.instance;
  var secure = DataSecurity();
  ChatCubit? chatCubit;
  ScrollController controller = ScrollController();

  Future<void> showImage(String imigUrl) {
    Encrypted encrypt = Encrypted.fromBase16(imigUrl);
    return showDialog(
      barrierColor: const Color.fromARGB(255, 36, 36, 36).withOpacity(0.9),
      context: context,
      builder: (context) {
        return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: CachedNetworkImage(
              filterQuality: FilterQuality.high,
              imageUrl: secure.decryptWithAES(encrypt),
              alignment: Alignment.center,
              height: 100,
              placeholder: (context, url) {
                return const Text('Loading..');
              },
            ));
      },
    );
  }

  void getmsg(int position) async {
    widget.lstUser?.clear();
    widget.lstUser = await chatCubit?.getMsg(
        FirebaseAuth.instance.currentUser!.uid,
        widget.lstUser?[position]['uid']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/chatting.png"),
              filterQuality: FilterQuality.high,
              fit: BoxFit.fill)),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Stack(children: [
        ListView.builder(
          reverse: true,
          scrollDirection: Axis.vertical,
          controller: controller,
          itemCount: widget.lstUser?.length,
          itemBuilder: (context, index) {
            Encrypted encrypted;
            if (widget.lstUser?[index]['image'] == null) {
              encrypted =
                  Encrypted.fromBase16(widget.lstUser?[index]['message']);
            } else {
              encrypted = Encrypted.fromBase16(widget.lstUser?[index]['image']);
            }

            if (widget.lstUser?[index]['sentBy'] == _auth.currentUser!.uid) {
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
                    color:
                        const Color.fromARGB(137, 22, 92, 59).withOpacity(0.8),
                    margin: const EdgeInsets.only(
                        left: 80, right: 0, top: 4, bottom: 4),
                    child: Padding(
                      padding: widget.lstUser?[index]['isImage'] == true
                          ? const EdgeInsets.all(4.0)
                          : const EdgeInsets.all(16.0),
                      child: widget.lstUser?[index]['isImage'] == true
                          ? GestureDetector(
                              onTap: () {
                                showImage(widget.lstUser?[index]['image']);
                              },
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20)),
                                child: CachedNetworkImage(
                                  imageUrl: secure.decryptWithAES(encrypted),
                                  placeholder: (context, url) {
                                    return const Text('Please Wait...');
                                  },
                                ),
                              ),
                            )
                          : Text(
                              secure.decryptWithAES(encrypted),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
                            ),
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(
                      (widget.lstUser?[index]['date'] as Timestamp).toDate(),
                    ),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white60,
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
                      color: const Color.fromARGB(131, 49, 53, 55)
                          .withOpacity(0.8),
                      margin: const EdgeInsets.only(
                          left: 0, right: 80, top: 4, bottom: 4),
                      child: Padding(
                        padding: widget.lstUser?[index]['isImage'] == true
                            ? const EdgeInsets.all(4.0)
                            : const EdgeInsets.all(16.0),
                        child: widget.lstUser?[index]['isImage'] == true
                            ? GestureDetector(
                                onTap: () {
                                  showImage(widget.lstUser?[index]['image']);
                                },
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20)),
                                  child: CachedNetworkImage(
                                    imageUrl: secure.decryptWithAES(encrypted),
                                    placeholder: (context, url) {
                                      return const Text('Please Wait...');
                                    },
                                  ),
                                ),
                              )
                            : Text(
                                secure.decryptWithAES(encrypted),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15),
                              ),
                      )),
                  Text(
                    DateFormat('hh:mm a').format(
                      (widget.lstUser?[index]['date'] as Timestamp).toDate(),
                    ),
                    style: const TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              );
            }
          },
        ),
      ]),
    );
  }
}
