import 'package:chapal/features/authentication/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserList extends StatelessWidget {
  UserList({super.key, required this.lstUser});
  List<Map<String, dynamic>>? lstUser;

  @override
  Widget build(BuildContext context) {
    FirebaseAuth current = FirebaseAuth.instance;
    return ListView.builder(
      itemCount: lstUser?.length,
      itemBuilder: (context, index) {
        print(lstUser?.length);

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
                  color: Colors.blue.withOpacity(0.5),
                  child: ListTile(
                      title: Text(
                        lstUser?[index]['name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      // subtitle: Text(
                      //   lstUser?[index]['message'] ?? 'No Data',
                      //   style: const TextStyle(color: Colors.white),
                      // ),
                      trailing: Text(
                        DateFormat('hh:mm a').format(
                            (lstUser?[index]['date'] as Timestamp).toDate()),
                        style: const TextStyle(color: Colors.white),
                      )),
                ),
              );
      },
    );
  }
}
