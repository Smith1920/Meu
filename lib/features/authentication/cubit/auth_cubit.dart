import 'package:chapal/features/authentication/cubit/auth_state.dart';
import 'package:chapal/features/authentication/modal/user_modal.dart';
import 'package:chapal/features/authentication/repository/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit(super.initialState);

  final AuthenticationRepository _authRepo = AuthenticationRepository();
  String result = '';
  Future<void> registerUser(
      String email, String name, String username, String password) async {
    emit(AuthenticationLoading(
      'Please Wait!',
    ));

    await _authRepo.registerUser(name, email, password, username);
    if (result == 'success') {
      emit(
        AuthenticationSuccess(false),
      );
    } else {
      emit(
        AuthenticationError('Something went wrong!!'),
      );
    }
  }

  Future<UserModal> loginuser(String email, String password) async {
    UserModal userDoc = UserModal(name: '', email: '', uid: '', username: '');
    emit(
      AuthenticationLoading('Please Wait!'),
    );
    Map<String, dynamic>? userData = await _authRepo.loginUser(email, password);

    if (userData != null) {
      emit(
        AuthenticationSuccess(true),
      );
      userDoc.name = userData['name'];
      userDoc.uid = userData['uid'];
      userDoc.username = userData['username'];
      userDoc.email = userData['email'];
    } else {
      emit(
        AuthenticationError('Something went wrong..'),
      );
    }
    return userDoc;
  }

  void getStatus(bool isLogin) {
    isLogin = !isLogin;
    emit(LoginRegister(isLogin));
  }

  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emit(
      AuthenticationLoading('Please Wait!'),
    );
    bool status = await _authRepo.logout();
    if (status == false) {
      emit(
        AuthenticationError('$status'),
      );
    } else {
      emit(
        AuthenticationSuccess(true),
      );

      prefs.remove('token');
    }

    return status;
  }

  Future<void> savingToken(String? uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (uid != null) {
      prefs.setString(
        'token',
        uid,
      );
    } else {}
  }

  Future<bool?> loadToken() async {
    emit(
      AuthenticationLoading('Please Wait.'),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkValue = prefs.containsKey('token');

    if (checkValue == true) {
      emit(
        LoggedIn(true),
      );
      return checkValue;
    } else {
      emit(
        LoggedIn(false),
      );
      return checkValue;
    }
  }
}
