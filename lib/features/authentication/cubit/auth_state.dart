

abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  AuthenticationSuccess(this.isLogin);
  bool isLogin = true;
}

class AuthenticationLoading extends AuthenticationState {
  AuthenticationLoading(this.msg);
  String msg;
}

class AuthenticationError extends AuthenticationState {
  AuthenticationError(this.msg);
  String msg;
}

class LoginRegister extends AuthenticationState {
  LoginRegister(this.isLogin);
  bool isLogin = true;
}

class LoggedIn extends AuthenticationState{
  LoggedIn(this.status);
  bool status=false;
}



