class ChatRoomModel {
  String? chatRoomId;
  String? lastMessage;
  //those two people who are chating with each others
  Map<String, dynamic>? participants;
  String? lastDate;
  List<dynamic>? users;

  ChatRoomModel(
      {this.chatRoomId, this.participants, this.lastMessage, this.lastDate,this.users});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map['chatRoomId'];
    lastMessage = map['lastMessage'];
    participants = map['participants'];
    lastDate = map['lastDate'];
    users = map['users'];
  }

  Map<String, dynamic> toMap() => {
        'chatRoomId': chatRoomId,
        'lastMessage': lastMessage,
        'participants': participants,
        'lastDate': lastDate,
        'users': users
      };
}
