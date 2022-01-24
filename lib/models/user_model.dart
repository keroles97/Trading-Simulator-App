class UserModel {
  String? name;
  String? email;
  String? uId;
  String? token;
  bool isVerified = false;
  List<String> sellingOrders = [];
  List<String> buyingOrders = [];

  UserModel({
    this.name,
    this.email,
    this.uId,
    this.token,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    email = json["email"];
    uId = json["uId"];
    token = json["token"];
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "uId": uId,
      "token": token,
    };
  }
}
