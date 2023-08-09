import 'package:chapal/features/authentication/cubit/chat_state.dart';
import 'package:chapal/features/authentication/repository/auth_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(super.initialState);
  final AuthenticationRepository _authRepo = AuthenticationRepository();
  List<Map<String, dynamic>> lstMsg = [];
  Map<String, dynamic> msg = {};
  CollectionReference firestore =
      FirebaseFirestore.instance.collection('users');
  String sendBy = '', sendTo = '';

  Future<void> sendMessage(
      String uid1, String uid2, String messages, bool isLoad) async {
    if (isLoad == false) {
      emit(ChatLoading());
    }
    String result = await _authRepo.sendMessage(uid1, uid2, messages);
    if (result == 'Success') {
      emit(ChatSuccess());
    } else {
      emit(ChatError());
    }
  }

  Future<List<Map<String, dynamic>>> getMsg(
      String sentBy, String sentTo) async {
    emit(ChatLoading());
    lstMsg.clear();
    lstMsg = await _authRepo.getMsg(sentBy, sentTo);
    if (lstMsg.isEmpty) {
      emit(
        ChatError(),
      );
    } else {
      for (int i = 0; i < lstMsg.length; i++) {
        print("SentBy: ${lstMsg[i]['sentBy']}");
        print("SentTo: ${lstMsg[i]['sentTo']}");
        print("Message: ${lstMsg[i]['message']}");
      }
      emit(ChatSuccess());
    }
    return lstMsg;
  }

  Future<void> setupListener() async {
    //_authRepo.setupListener(sentBy, sentTo);
    emit(ChatSuccess());
  }

  Future<void> setLastMsg(String sentBy, String sentTo, val) async {
    sendBy = sentBy;
    sendTo = sentTo;
    await firestore.doc(sentBy).update({
      'message': val,
      'date': DateFormat('hh:mm a').format(
        DateTime.now(),
      )
    });

    await firestore.doc(sentTo).update({
      'message': val,
      'date': DateFormat('hh:mm a').format(
        DateTime.now(),
      ),
    });
  }

  
}
