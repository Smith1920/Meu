import 'package:chapal/features/authentication/cubit/chat_cubit.dart';
import 'package:chapal/features/authentication/cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveChatScreen extends StatefulWidget {
  const ActiveChatScreen({super.key});

  @override
  State<ActiveChatScreen> createState() => _ActiveChatScreenState();
}

class _ActiveChatScreenState extends State<ActiveChatScreen> {
  List<Map<String,dynamic>> lstActiveUser = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ChatSuccess) {
          return ListView.builder(
            itemCount: lstActiveUser.length,
            itemBuilder: (context, index) {},
          );
        }else{
          return Container(child: Text('data'),);
        }
      },
    ));
  }
}
