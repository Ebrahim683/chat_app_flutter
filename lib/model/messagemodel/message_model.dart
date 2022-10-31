class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  String? createdOn;
  String? image;

  MessageModel(
      {this.messageId,
      this.sender,
      this.text,
      this.seen,
      this.createdOn,
      this.image});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map['messageId'];
    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    createdOn = map['createdOn'];
    image = map['image'];
  }

  Map<String, dynamic> toMap() => {
        'messageId': messageId,
        'sender': sender,
        'text': text,
        'seen': seen,
        'createdOn': createdOn,
        'image': image,
      };
}
