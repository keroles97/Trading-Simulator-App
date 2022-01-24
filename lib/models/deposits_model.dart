import 'package:intl/intl.dart' as intl;

class DepositsModel {
  String? id;
  Object? date;
  String? amount;
  String? amountMinusFee;

  DepositsModel({
    this.id,
    this.date,
    this.amount,
    this.amountMinusFee
  });

  DepositsModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    date = json["date"].toString();
    amount = json["amount"];
    amountMinusFee = json["amountMinusFee"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "date": date,
      "amount": amount,
      "amountMinusFee": amountMinusFee,
    };
  }
}
