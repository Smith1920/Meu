import 'package:chapal/features/authentication/cubit/auth_state.dart';
import 'package:chapal/features/authentication/cubit/chat_cubit.dart';
import 'package:chapal/features/authentication/repository/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MessageCubit extends Cubit<AuthenticationState> {
  MessageCubit(super.initialState);
  final AuthenticationRepository _authRepo = AuthenticationRepository();
  ChatCubit? _chatCubit;
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    emit(AuthenticationLoading('Please Wait!'));
    List<Map<String, dynamic>> lstUser = await _authRepo.getAllUsers();
    if (lstUser.isEmpty) {
      Fluttertoast.showToast(msg: 'List is empty..');
      emit(
        AuthenticationError('Something went wrong..'),
      );
    }
    emit(
      AuthenticationSuccess(true),
    );

    return lstUser;
  }

  // Future<Map<String, dynamic>?> getLastMsg() async {
  //   return _chatCubit?.getLastMsg();
  // }

 

  Future<void> refresh() async {
    emit(AuthenticationSuccess(true));
  }
}
