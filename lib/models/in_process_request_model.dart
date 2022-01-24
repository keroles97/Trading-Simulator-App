class InProcessRequestModel {
  String? id;
  String? sellerUId;
  String? buyerUId;
  Object? date;
  String? currency;
  String? amount;
  String? pricePerCoin;
  String? totalPrice;
  String? fees;
  String? totalCost;

  InProcessRequestModel({
    this.id,
    this.sellerUId,
    this.buyerUId,
    this.date,
    this.currency,
    this.amount,
    this.pricePerCoin,
    this.totalPrice,
    this.fees,
    this.totalCost
  });

  InProcessRequestModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    sellerUId = json["sellerUId"];
    buyerUId = json["buyerUId"];
    date = json["date"].toString();
    currency = json["currency"];
    amount = json["amount"];
    pricePerCoin = json["pricePerCoin"];
    totalPrice = json["totalPrice"];
    fees = json["fees"];
    totalCost = json["totalCost"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "sellerUId": sellerUId,
      "buyerUId": buyerUId,
      "date": date,
      "currency": currency,
      "amount": amount,
      "pricePerCoin": pricePerCoin,
      "totalPrice": totalPrice,
      "fees": fees,
      "totalCost": totalCost,
    };
  }
}
