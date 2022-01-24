import 'package:intl/intl.dart' as intl;

class RequestWithdrawalsModel {
  String? uId;
  String? email;
  Object? date;
  String? amount;

  RequestWithdrawalsModel({
    this.uId,
    this.email,
    this.date,
    this.amount,
  });

  RequestWithdrawalsModel.fromJson(Map<String, dynamic> json) {
    uId = json["uId"];
    email = json["email"];
    date = formatDateTime(json["date"].toString());
    amount = json["amount"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uId": uId,
      "email": email,
      "date": date,
      "amount": amount,
    };
  }
  String formatDateTime(Object dateTime) {
    var dt =
    DateTime.fromMillisecondsSinceEpoch(int.parse(dateTime.toString()));
    var d24 = intl.DateFormat('HH:mm, dd/MM/yyyy').format(dt);
    return d24.toString();
  }
}
