import 'package:chapal/features/authentication/modal/chat_info.dart';
import 'package:chapal/features/authentication/modal/chat_modal.dart';
import 'package:chapal/features/authentication/modal/user_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> lstUser = [];
  List<Map<String, dynamic>> lstMsg = [];
  String result = '';
  String sendTo='';
  String chatID = '';
  Map<String, dynamic> userData = {};

  Future<String> registerUser(
      String name, String email, String password, String username) async {
    result = "Some Error Occured";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential user = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(user.user!.uid);

        UserModal userModal = UserModal(
            name: name, email: email, uid: user.user!.uid, username: username);
        await _firestore.collection('users').doc(user.user!.uid).set(
          {
            'name': userModal.name,
            'email': userModal.email,
            'uid': userModal.uid,
            'username': userModal.username,
            'message': '',
            'date': '',
          },
        );
        result = 'success';
      }
    } catch (e) {
      result = e.toString();
    }

    return result;
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    result = "Some Error Occured";

    DocumentSnapshot snapshot;
    CollectionReference firestoreData =
        FirebaseFirestore.instance.collection('users');
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential user = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        snapshot = await firestoreData.doc(user.user!.uid).get();

        if (snapshot.exists) {
          userData = snapshot.data() as Map<String, dynamic>;
        }

        result = 'UID: ${userData['uid']}';
      }
    } catch (e) {
      result = e.toString();
    }

    return userData;
  }

  Future<bool> logout() async {
    await FirebaseAuth.instance.signOut();
    if (FirebaseAuth.instance.currentUser == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    List<Map<String, dynamic>> userList = [];
    CollectionReference userCollection =
        await FirebaseFirestore.instance.collection('users');

    try {
      QuerySnapshot snapshot = await userCollection.get();

      for (QueryDocumentSnapshot documentSnapshot in snapshot.docs) {
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;

        userList.add(userData);
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
    return userList;
  }

  Future<Map<String, dynamic>> getCurrentUser(String uid) async {
    DocumentSnapshot snapshot;
    CollectionReference firestoreData =
        FirebaseFirestore.instance.collection('users');
    try {
      snapshot = await firestoreData.doc(uid).get();
      if (snapshot.exists) {
        userData = snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }

    return userData;
  }

  Future<String> sendMessage(String uid1, String uid2, String messages) async {
    String result = '';
    String uid = "${uid1}_$uid2";
    sendTo=uid2;
    ChatInfo chatInfo;
    CollectionReference chatCollection = _firestore.collection('chats');
    bool flag = false;

    try {
      chatInfo = ChatInfo(
        sentBy: uid1,
        sentTo: uid2,
        message: messages,
        date: DateTime.now(),
      );

      ChatModal(
        lstUser: [uid1, uid2],
        message: chatInfo,
        createdAt: DateTime.now(),
      );
      chatCollection = _firestore.collection('chats');

      QuerySnapshot chatList = await chatCollection.get();
      List<Map<String, dynamic>> lstChat = [];

      chatList.docs.forEach((doc) {
        lstChat.add(doc.data() as Map<String, dynamic>);
      });

      if (chatList.size > 0) {
        for (int i = 0; i < lstChat.length; i++) {
          if ((lstChat[i]['user'][0] == uid1 ||
                  lstChat[i]['user'][0] == uid2) &&
              (lstChat[i]['user'][1] == uid1 ||
                  lstChat[i]['user'][1] == uid2) &&
              flag == false) {
            chatID = lstChat[i]['uid'];
            chatCollection.doc(lstChat[i]['uid']).collection('messages').add({
              'sentBy': chatInfo.sentBy,
              'sentTo': chatInfo.sentTo,
              'date': chatInfo.date,
              'message': chatInfo.message,
            });
            flag = true;
          }
        }
      }

      if (flag == false) {
        await chatCollection.doc(uid).set({
          'uid': uid,
          'user': [uid1, uid2],
          'date': chatInfo.date,
        });

        await chatCollection.doc(uid).collection('messages').doc().set({
          'sentBy': chatInfo.sentBy,
          'sentTo': chatInfo.sentTo,
          'date': chatInfo.date,
          'message': chatInfo.message,
        });
        chatID = uid;
        flag = true;
      }

      result = "Success";
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getMsg(
      String sentBy, String sentTo) async {
    QuerySnapshot messages1 = await _firestore
        .collection('chats')
        .doc("${sentBy}_$sentTo")
        .collection('messages')
        .orderBy('date', descending: true)
        .get();

    QuerySnapshot messages2 = await _firestore
        .collection('chats')
        .doc("${sentTo}_$sentBy")
        .collection('messages')
        .orderBy('date', descending: true)
        .get();

    if (messages1.docs.isNotEmpty) {
      for (QueryDocumentSnapshot chatMessage in messages1.docs) {
        lstUser.add(chatMessage.data() as Map<String, dynamic>);
      }
    } else {
      for (QueryDocumentSnapshot chatMessage in messages2.docs) {
        lstUser.add(chatMessage.data() as Map<String, dynamic>);
      }
    }

    return lstUser;
  }

  Future<List<Map<String, dynamic>>> setupListener(
      String sentBy, String sentTo, String message) async {
    _firestore
        .collection('chats')
        .doc("${sentBy}_$sentTo")
        .collection('messages')
        .orderBy('date', descending: false)
        .snapshots()
        .listen((event) {
      print("Length of chats: ${lstUser.length}");
      print(event.docs.last.data().toString());
      lstUser.add(event.docs.last.data());
    });

    _firestore
        .collection('chats')
        .doc("${sentBy}_$sentBy")
        .collection('messages')
        .orderBy('date', descending: false)
        .snapshots()
        .listen((event) {
      print("Length of chats: ${lstUser.length}");
      print(event.docs.last.data().toString());
      lstUser.add(event.docs.last.data());
    });
    return lstUser;
  }
   
}
