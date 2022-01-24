class WithdrawalsModel {
  String? id;
  String? email;
  Object? date;
  String? amount;

  WithdrawalsModel({
    this.id,
    this.email,
    this.date,
    this.amount,
  });

  WithdrawalsModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    email = json["email"];
    date = json["date"].toString();
    amount = json["amount"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "date": date,
      "amount": amount,
    };
  }
}
