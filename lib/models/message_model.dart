class MessageModel {
  bool? senderIsUser;
  String? body;
  Object? date;

  MessageModel({
    this.senderIsUser,
    this.body,
    this.date,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    senderIsUser = json["senderIsUser"];
    body = json["body"];
    date = json["date"].toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "senderIsUser": senderIsUser,
      "body": body,
      "date": date,
    };
  }
}
