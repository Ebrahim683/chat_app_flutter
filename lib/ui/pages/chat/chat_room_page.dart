import 'dart:developer';
import 'dart:io';

import 'package:chat_app_flutter/controller/chat_controller.dart';
import 'package:chat_app_flutter/main.dart';
import 'package:chat_app_flutter/model/callmodel/video_call_id_model.dart';
import 'package:chat_app_flutter/model/chatroommodel/chat_room_model.dart';
import 'package:chat_app_flutter/model/messagemodel/message_model.dart';
import 'package:chat_app_flutter/model/usermodel/user_model.dart';
import 'package:chat_app_flutter/ui/pages/callpage/video_call_page.dart';
import 'package:chat_app_flutter/utils/getstoragemanager/get_storage_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
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

  final _controller = Get.put(ChatController());
  String? myId;
  String? friendsId;
  File? selectedImage;

  var videoStore;
  var myVideoId;

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

    if (_controller.imagePath.value != '') {
      selectedImage = File(_controller.imagePath.value);
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage
          .ref('messageImages')
          .child(GetStorageManager.getToken())
          .child(uuid.v1().toString());
      await ref.putFile(selectedImage!);
      // UploadTask uploadTaskImage = FirebaseStorage.instance
      //     .ref('messageImages')
      //     .child(GetStorageManager.getToken())
      //     .child(uuid.v1().toString())
      //     .putFile(selectedImage!);
      // var snapshot = uploadTaskImage as TaskSnapshot;
      String getUrl = await ref.getDownloadURL();
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
      _controller.imagePath.value = '';
      log('message send');
    } else {
      Get.snackbar("Error!", 'No message', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // final databaseReference = FirebaseDatabase.instance
  //     .ref('videocallroom')
  //     .child(GetStorageManager.getToken());

  VideoCallIdModel? videoCallIdModel;

  createVideoRoom(String data) async {
    videoCallIdModel = VideoCallIdModel(videoRoomId: data);
    // await databaseReference.set(videoCallIdModel?.toJson());
    videoStore.set(videoCallIdModel!.toJson());
  }

  String? videoRoomId;

  getVideoRoomIdWhenMakeCall() async {
    await videoStore.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        videoCallIdModel = VideoCallIdModel.fromMap(data);
        log('videoId: ${videoCallIdModel!.videoRoomId}');
        setState(() {
          videoRoomId = data['videoRoomId'].toString();
        });
      },
      onError: (e) => log("Error getting document: $e"),
    );

    if (videoRoomId == 'true') {
      log('2nd ${videoRoomId.toString()}');
      makeVideoCall(
          videoRoomId.toString(), widget.userModel.fullName.toString());
    } else {
      log('empty');
    }
  }

  getVideoRoomIdWhenInit() async {
    await myVideoId.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        videoCallIdModel = VideoCallIdModel.fromMap(data);
        log('videoId: ${videoCallIdModel!.videoRoomId}');
        setState(() {
          videoRoomId = data['videoRoomId'].toString();
        });
      },
      onError: (e) => log("Error getting document: $e"),
    );

    if (videoRoomId == 'true') {
      log('2nd ${videoRoomId.toString()}');
      makeVideoCall(
          videoRoomId.toString(), widget.userModel.fullName.toString());
    } else {
      log('empty');
    }
  }

  checkVideoCall() async {
    myVideoId = FirebaseFirestore.instance
        .collection('videoRoom')
        .doc(GetStorageManager.getToken());

    videoCallIdModel = VideoCallIdModel(videoRoomId: 'false');
    // await databaseReference.set(videoCallIdModel?.toJson());
    myVideoId.set(videoCallIdModel!.toJson());
  }

  makeVideoCall(String callId, String userName) {
    Get.to(VideoCallPage(
      callId: callId,
      userName: userName,
      targetUserId: widget.targetUserModel.userId.toString(),
      myUid: widget.userModel.userId.toString(),
    ));
  }

  @override
  void initState() {
    super.initState();
    videoStore = FirebaseFirestore.instance
        .collection('videoRoom')
        .doc(widget.targetUserModel.userId);
    createVideoRoom('false');
    checkVideoCall();
    getVideoRoomIdWhenMakeCall();
    // getVideoRoomIdWhenInit();
    myId = widget.userModel.userId;
    friendsId = widget.targetUserModel.userId;
    log('my id: $myId');
    log('friend id: $friendsId');
  }

  @override
  void dispose() {
    super.dispose();
    createVideoRoom('false');
    log('disposed');
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
        actions: [
          IconButton(
            onPressed: () {
              createVideoRoom('true');
              getVideoRoomIdWhenMakeCall();
            },
            icon: const Icon(Icons.video_call_sharp),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            //video call
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('videoRoom')
                  // .doc(GetStorageManager.getToken())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                  videoCallIdModel = VideoCallIdModel.fromMap(
                      querySnapshot.docs[0].data() as Map<String, dynamic>);
                  log('dd:${videoCallIdModel!.videoRoomId.toString()}');
                  if (videoCallIdModel!.videoRoomId == 'true') {
                    Future.microtask(() => {
                          makeVideoCall(
                              videoCallIdModel!.videoRoomId.toString(),
                              widget.userModel.fullName.toString())
                        });
                  }
                  return Container();
                } else {
                  return Container();
                }
              },
            ),
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
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot querySnapshot =
                            snapshot.data as QuerySnapshot;
                        return ListView.builder(
                            reverse: true,
                            itemCount: querySnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(querySnapshot.docs[index]
                                      .data() as Map<String, dynamic>);
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
                                            ? Color.fromARGB(255, 120, 54, 244)
                                            // ignore: prefer_const_constructors
                                            : Color.fromARGB(255, 92, 78, 59)),
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
                  IconButton(
                    onPressed: () {
                      _controller.getImage();
                    },
                    icon: Obx(
                      () => _controller.imagePath == ''
                          ? Icon(Icons.image)
                          : Image.file(
                              File(_controller.imagePath.value),
                            ),
                    ),
                  ),
                  Flexible(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: TextField(
                      controller: messageController,
                      maxLines: null,
                      decoration: const InputDecoration(hintText: 'Message'),
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
        ),
      ),
    );
  }
}
