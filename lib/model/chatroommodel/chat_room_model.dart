class ChatRoomModel {
  String? chatRoomId;
  //those two people who are chating with each others
  List<String>? participants;

  ChatRoomModel({this.chatRoomId, this.participants});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map['chatRoomId'];
    participants = map['participants'];
  }

  Map<String, dynamic> toMap() =>
      {'chatRoomId': chatRoomId, 'participants': participants};
}
