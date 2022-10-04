import 'package:chat_app_flutter/constant/app_constant.dart';
import 'package:chat_app_flutter/firebase/FirebaseHelper.dart';
import 'package:chat_app_flutter/model/usermodel/user_model.dart';
import 'package:chat_app_flutter/ui/pages/auth/sign_in_page.dart';
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
        child: Center(),
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
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(profilePic),
              child: profilePic == null
                  ? const Icon(Icons.person)
                  : const Center(),
            ),
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
