import 'package:chat_app_flutter/constant/app_constant.dart';
import 'package:chat_app_flutter/firebase/FirebaseHelper.dart';
import 'package:chat_app_flutter/model/chatroommodel/chat_room_model.dart';
import 'package:chat_app_flutter/model/usermodel/user_model.dart';
import 'package:chat_app_flutter/ui/pages/auth/sign_in_page.dart';
import 'package:chat_app_flutter/ui/pages/chat/chat_room_page.dart';
import 'package:chat_app_flutter/ui/pages/profile/profile_page.dart';
import 'package:chat_app_flutter/ui/pages/search/search_page.dart';
import 'package:chat_app_flutter/utils/getstoragemanager/get_storage_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var uid = GetStorageManager.getToken();

  UserModel? userModel;
  String profilePic = '';

  //log out
  logOut() {
    GetStorageManager.logOut();
    setState(() {
      AppConstant.goToFinal(context, const SignInPage());
    });
  }

  //get user info
  getUserInfo() async {
    userModel = await FirebaseHelper.getUserModel(uid);
    setState(() {
      profilePic = userModel!.profilePic.toString();
    });
  }

  @override
  void initState() {
    print('home:$uid');
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where('users', arrayContains: userModel?.userId)
                // .orderBy('lastDate')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                  if (querySnapshot.docs.length > 0) {
                    return ListView.builder(
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (context, index) {
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                            querySnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        Map<String, dynamic> participants =
                            chatRoomModel.participants!;
                        List<String> participantsKey =
                            participants.keys.toList();
                        participantsKey.remove(userModel?.userId);
                        return FutureBuilder(
                          future:
                              FirebaseHelper.getUserModel(participantsKey[0]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data != null) {
                                UserModel targetUserModel =
                                    snapshot.data as UserModel;
                                return ListTile(
                                  onTap: () {
                                    setState(() {
                                      AppConstant.goTo(
                                          context,
                                          ChatRoomPage(
                                              targetUserModel: targetUserModel,
                                              chatRoomModel: chatRoomModel,
                                              userModel: userModel!));
                                    });
                                  },
                                  title:
                                      Text(targetUserModel.fullName.toString()),
                                  subtitle: Text(
                                      chatRoomModel.lastMessage.toString()),
                                  leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          targetUserModel.profilePic
                                              .toString())),
                                );
                              } else {
                                return const Center();
                              }
                            } else {
                              return const Center();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text('${snapshot.error}'),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
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
            },
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.withOpacity(0.4),
        elevation: 0,
        title: const Text("My Chat"),
        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: GestureDetector(
            onTap: () {
              setState(() {
                AppConstant.goTo(context, const ProfilePage());
              });
            },
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('usersData')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      DocumentSnapshot? querySnapshot =
                          snapshot.data as DocumentSnapshot;
                      dynamic data = querySnapshot.data();
                      UserModel profilePicUserModel = UserModel.fromMap(data);
                      return CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                            profilePicUserModel.profilePic.toString()),
                      );
                    } else {
                      return const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person),
                      );
                    }
                  } else {
                    return const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person),
                    );
                  }
                }),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 5.w),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    AppConstant.goTo(
                        context, SearchPage(userModel: userModel!));
                  });
                },
                icon: const Icon(Icons.search)),
          ),
          Padding(
            padding: EdgeInsets.only(right: 5.w),
            child: IconButton(
                onPressed: () {
                  logOut();
                },
                icon: const Icon(Icons.logout)),
          ),
        ],
      ),
    );
  }
}
