import 'package:chapal/features/authentication/modal/chat_info.dart';

class ChatModal {
  ChatModal({
    required this.lstUser,
    required this.message,
    required this.createdAt,
  });
  List<String> lstUser;
  ChatInfo message;
  DateTime createdAt;
}
