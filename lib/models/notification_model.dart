
class NotificationModel {
  String? alert;
  Object? date;

  NotificationModel({
    this.alert,
    this.date,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    alert = json["alert"];
    date = json["date"].toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "email": alert,
      "date": date,
    };
  }
}
