class ChatRoomModel {
  String? chatRoomId;
  String? lastMessage;
  //those two people who are chating with each others
  Map<String, dynamic>? participants;

  ChatRoomModel({this.chatRoomId, this.participants, this.lastMessage});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map['chatRoomId'];
    lastMessage = map['lastMessage'];
    participants = map['participants'];
  }

  Map<String, dynamic> toMap() => {
        'chatRoomId': chatRoomId,
        'lastMessage': lastMessage,
        'participants': participants
      };
}
