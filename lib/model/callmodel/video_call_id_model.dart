class VideoCallIdModel {
  String? videoRoomId;

  VideoCallIdModel({this.videoRoomId});

  VideoCallIdModel.fromMap(Map<String, dynamic> map) {
    videoRoomId = map['videoRoomId'];
  }

  Map<String, dynamic> toJson() => {
        'videoRoomId': videoRoomId,
      };
}
