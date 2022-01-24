class CurrencyModel {
  String? code;
  String? value;

  CurrencyModel({
    this.code,
    this.value,
  });

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    code = json["code"];
    value = json["value"];
  }

  Map<String, dynamic> toMap() {
    return {
      "code": code,
      "value": value,
    };
  }
}
