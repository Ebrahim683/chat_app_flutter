import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? userId;
  String? fullName;
  String? emailAddress;
  String? profilePic;

  UserModel({this.userId, this.fullName, this.emailAddress, this.profilePic});

  UserModel.fromMap(Map<String, dynamic> map) {
    userId = map['userId'];
    fullName = map['fullName'];
    emailAddress = map['emailAddress'];
    profilePic = map['profilePic'];
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'fullName': fullName,
        'emailAddress': emailAddress,
        'profilePic': profilePic
      };
}
