import 'package:chat_app_flutter/model/usermodel/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModel(String uid) async {
    UserModel? userModel;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('usersData')
          .doc(uid)
          .get();
      dynamic data = snapshot.data();
      userModel = UserModel.fromMap(data);
      print('getUserModel:${userModel.emailAddress}');
    } catch (e) {
      print('getUserModel: $e');
    }
    return userModel!;
  }
}
