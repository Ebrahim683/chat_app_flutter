import 'dart:developer';

import 'package:chat_app_flutter/constant/app_constant.dart';
import 'package:chat_app_flutter/model/callmodel/video_call_id_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallPage extends StatefulWidget {
  final String callId;
  final String targetUserId;
  final String myUid;
  final String userName;
  const VideoCallPage(
      {super.key,
      required this.callId,
      required this.userName,
      required this.targetUserId,
      required this.myUid});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  var videoStore;
  var myVideoId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log(widget.callId);
    log(widget.userName);
    log(widget.targetUserId);
    log(widget.myUid);
  }

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: AppConstant.videoAppId,
      appSign: AppConstant.videoAppSignIn,
      callID: widget.callId,
      userID: '${widget.userName}-${widget.callId}',
      userName: widget.userName,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..onOnlySelfInRoom = (context) {
          VideoCallIdModel videoCallIdModel =
              VideoCallIdModel(videoRoomId: 'false');

          videoStore = FirebaseFirestore.instance
              .collection('videoRoom')
              .doc(widget.targetUserId)
              .set(videoCallIdModel.toJson());

          myVideoId = FirebaseFirestore.instance
              .collection('videoRoom')
              .doc(widget.myUid)
              .set(videoCallIdModel.toJson());
          Get.back();
        },
    );
  }
}
