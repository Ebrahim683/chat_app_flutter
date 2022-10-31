import 'dart:developer';
import 'dart:io';

import 'package:chat_app_flutter/controller/chat_controller.dart';
import 'package:chat_app_flutter/main.dart';
import 'package:chat_app_flutter/model/chatroommodel/chat_room_model.dart';
import 'package:chat_app_flutter/model/messagemodel/message_model.dart';
import 'package:chat_app_flutter/model/usermodel/user_model.dart';
import 'package:chat_app_flutter/utils/getstoragemanager/get_storage_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUserModel;
  final ChatRoomModel chatRoomModel;
  final UserModel userModel;

  const ChatRoomPage(
      {super.key,
      required this.targetUserModel,
      required this.chatRoomModel,
      required this.userModel});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final messageController = TextEditingController();

  File? selectedImage;

  getImage() async {
    XFile? selectImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (selectImage != null) {
      File castFile = File(selectImage.path);
      setState(() {
        selectedImage = castFile;
      });
      log('selected image: $selectedImage');
    }
  }

  void sendMessage() async {
    String message = messageController.text.toString();
    messageController.clear();

    String? imageUrl;

    if (selectedImage != null) {
      UploadTask uploadTaskImage = FirebaseStorage.instance
          .ref('messageImages')
          .child(GetStorageManager.getToken())
          .child(uuid.v1().toString())
          .putFile(selectedImage!);
      TaskSnapshot snapshot = uploadTaskImage as TaskSnapshot;
      String getUrl = snapshot.ref.getDownloadURL() as String;
      setState(() {
        imageUrl = getUrl;
        selectedImage = null;
      });
      log('imageUrl: $imageUrl');
    }

    if (message.isNotEmpty || imageUrl != null) {
      MessageModel messageModel = MessageModel(
          messageId: uuid.v1(),
          sender: widget.userModel.userId,
          createdOn: DateTime.now().toString(),
          seen: false,
          text: message == null ? '' : message,
          image: imageUrl == "" ? "" : imageUrl);

      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoomModel.chatRoomId)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(messageModel.toMap());
      widget.chatRoomModel.lastMessage = message;

      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoomModel.chatRoomId)
          .set(widget.chatRoomModel.toMap());
      log('message send');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  NetworkImage(widget.targetUserModel.profilePic.toString()),
            ),
            SizedBox(width: 10.w),
            Column(
              children: [
                Text(
                  widget.targetUserModel.fullName.toString(),
                  style: TextStyle(fontSize: 15.sp),
                ),
                Text(
                  widget.targetUserModel.emailAddress.toString(),
                  style: TextStyle(fontSize: 10.sp),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: GetBuilder<ChatController>(
          builder: (controller) {
            return Column(
              children: [
                //message list
                Expanded(
                  child: Container(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('chatrooms')
                          .doc(widget.chatRoomModel.chatRoomId)
                          .collection('messages')
                          .orderBy('createdOn', descending: true)
                          .snapshots(),
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot querySnapshot =
                                snapshot.data as QuerySnapshot;
                            return ListView.builder(
                                reverse: true,
                                itemCount: querySnapshot.docs.length,
                                itemBuilder: (context, index) {
                                  MessageModel currentMessage =
                                      MessageModel.fromMap(
                                          querySnapshot.docs[index].data()
                                              as Map<String, dynamic>);
                                  return Row(
                                    mainAxisAlignment: (currentMessage.sender ==
                                            widget.userModel.userId)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5.w, horizontal: 5.w),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5.w, vertical: 5.h),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                            color: (currentMessage.sender ==
                                                    widget.userModel.userId)
                                                // ignore: prefer_const_constructors
                                                ? Color.fromARGB(
                                                    255, 120, 54, 244)
                                                // ignore: prefer_const_constructors
                                                : Color.fromARGB(
                                                    255, 92, 78, 59)),
                                        child: Column(
                                          children: [
                                            Text(
                                              currentMessage.text.toString(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            return const Center(
                              child: Text('No chats'),
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                    ),
                  ),
                ),
                //message input
                Container(
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Row(
                    children: [
                      // IconButton(
                      //     onPressed: () {
                      //       controller.getImage();
                      //     },
                      //     icon: const Icon(Icons.image)),
                      Flexible(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: const InputDecoration(
                              // prefix: controller.selectedImage == null
                              //     ? Container()
                              //     : Image.file(
                              //         controller.selectedImage!,
                              //         height: 40.h,
                              //         width: 40.w,
                              //       ),
                              hintText: 'Message'),
                        ),
                      )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              sendMessage();
                            });
                          },
                          icon: const Icon(Icons.send))
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
