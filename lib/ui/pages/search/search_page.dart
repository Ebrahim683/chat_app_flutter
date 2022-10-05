import 'dart:developer';

import 'package:chat_app_flutter/constant/app_constant.dart';
import 'package:chat_app_flutter/main.dart';
import 'package:chat_app_flutter/model/chatroommodel/chat_room_model.dart';
import 'package:chat_app_flutter/model/usermodel/user_model.dart';
import 'package:chat_app_flutter/ui/pages/chat/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;

  const SearchPage({super.key, required this.userModel});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();

  //make chat room
  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUserModel) async {
    ChatRoomModel? chatRoomModel;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.userModel.userId}', isEqualTo: true)
        .where('participants.${targetUserModel.userId}', isEqualTo: true)
        .get();
    if (querySnapshot.docs.length > 0) {
      var docData = querySnapshot.docs[0].data();
      ChatRoomModel existingChatRoomModel =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      log('chat room fetched');
      chatRoomModel = existingChatRoomModel;
    } else {
      ChatRoomModel newChatRoomModel = ChatRoomModel(
          chatRoomId: uuid.v1(),
          lastMessage: '',
          participants: {
            widget.userModel.userId.toString(): true,
            targetUserModel.userId.toString(): true,
          },
          lastDate: DateTime.now().toString(),
          users: [
            widget.userModel.userId.toString(),
            targetUserModel.userId.toString()
          ]);

      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatRoomModel.chatRoomId)
          .set(newChatRoomModel.toMap());
      log('new chat room created');
      chatRoomModel = newChatRoomModel;
    }
    return chatRoomModel;
  }

  @override
  void initState() {
    print('search: ${widget.userModel.emailAddress}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 15.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(hintText: 'Email address'),
              ),
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text('Search')),
            SizedBox(height: 10.h),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('usersData')
                    .where('emailAddress', isEqualTo: searchController.text)
                    .where('emailAddress',
                        isNotEqualTo: widget.userModel.emailAddress)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot querySnapshot =
                          snapshot.data as QuerySnapshot;

                      if (querySnapshot.docs.isNotEmpty) {
                        Map<String, dynamic> map = querySnapshot.docs[0].data()
                            as Map<String, dynamic>;
                        UserModel searchedUserModel = UserModel.fromMap(map);
                        return ListTile(
                          title: Text(searchedUserModel.fullName.toString()),
                          subtitle:
                              Text(searchedUserModel.emailAddress.toString()),
                          leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  '${searchedUserModel.profilePic}')),
                          onTap: (() async {
                            ChatRoomModel? chatRoomModel =
                                await getChatRoomModel(searchedUserModel);
                            if (chatRoomModel != null) {
                              setState(() {
                                AppConstant.goToFinal(
                                    context,
                                    ChatRoomPage(
                                      targetUserModel: searchedUserModel,
                                      userModel: widget.userModel,
                                      chatRoomModel: chatRoomModel,
                                    ));
                              });
                            }
                          }),
                        );
                      } else {
                        return const Text('No result found');
                      }
                    } else {
                      return const Text('No result found');
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
