import 'dart:io';

import 'package:chat_app_flutter/constant/app_constant.dart';
import 'package:chat_app_flutter/model/usermodel/user_model.dart';
import 'package:chat_app_flutter/utils/getstoragemanager/get_storage_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? emailAddress;
  String? fullName;
  File? imageFile;
  String? profileImage;
  final TextEditingController _fullNameController = TextEditingController();
  UserModel _userModel = UserModel();

//select image
  selectImage(ImageSource source) async {
    XFile? file = await ImagePicker().pickImage(source: source);

    if (file != null) {
      cropImage(file);
    }
  }

//crop image
  cropImage(XFile file) async {
    var croppedImage = (await ImageCropper().cropImage(
        sourcePath: file.path,
        compressQuality: 30,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1)));

    if (croppedImage != null) {
      File? castFile = File(croppedImage.path);
      setState(() {
        imageFile = castFile;
      });
    }
  }

//bottom sheet
  void showPhotoOptions() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  Text(
                    'Upload photo',
                    style: TextStyle(fontSize: 20.sp),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      selectImage(ImageSource.gallery);
                    },
                    title: const Text('Select from gallery'),
                    leading: const Icon(Icons.photo_album_outlined),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      selectImage(ImageSource.camera);
                    },
                    title: const Text('Take a photo'),
                    leading: const Icon(Icons.camera_alt_outlined),
                  ),
                ],
              ),
            ),
          );
        });
  }

  //get user info
  getUserInfo() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('usersData')
          .doc(GetStorageManager.getToken())
          .get();
      dynamic data = snapshot.data();
      UserModel userModel = UserModel.fromMap(data);
      setState(() {
        _userModel = userModel;
        emailAddress = _userModel.emailAddress.toString();
        fullName = _userModel.fullName.toString();
        profileImage = _userModel.profilePic;
      });
      print('profile:$profileImage');
      print('profile:${_userModel.profilePic}');
    } catch (e) {
      print('profile: $e');
    }
  }

//update info
  updateInfo() async {
    String name = _fullNameController.text.toString();

    if (imageFile != null) {
      var updatedName = name == '' ? fullName : name;
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('profilePictures')
          .child(GetStorageManager.getToken().toString())
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;
      String getUrl = await snapshot.ref.getDownloadURL();
      _userModel.fullName = updatedName;
      _userModel.profilePic = getUrl;
      await FirebaseFirestore.instance
          .collection('usersData')
          .doc(GetStorageManager.getToken().toString())
          .set(_userModel.toMap())
          .then((value) {
        print('profile: data updated');
      });
    } else {
      AppConstant.snackBar(
          context: context, msg: 'Please fill the form and profile pic');
    }
  }

  //show profile pic
  ImageProvider? showProfilePic() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    }
    if (profileImage != null) {
      return NetworkImage(profileImage.toString());
    }
    return null;
  }

  //set avater
  Widget? setAvater() {
    if (profileImage == null && imageFile == null) {
      return Icon(
        Icons.person,
        size: 50,
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: SizedBox(
                  height: 120.h,
                  width: 120.w,
                  child: GestureDetector(
                    onTap: () {
                      showPhotoOptions();
                    },
                    child: CircleAvatar(
                      backgroundImage: showProfilePic(),
                      child: Expanded(child: Center(child: setAvater())),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: fullName ?? 'Loading...',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                emailAddress ?? 'Loading...',
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    updateInfo();
                  },
                  child: Text('Update'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
