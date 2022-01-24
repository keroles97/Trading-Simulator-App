import 'dart:async';
import 'dart:convert';

import 'package:app/models/http_exception_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';

class PaypalServices {
  //String domain = "https://api-m.sandbox.paypal.com"; // for sandbox mode
  String domain = "https://api.paypal.com"; // for production mode

  // change clientId and secret with your own, provided by paypal

  // for testing

  // String clientId =
  //     'AS26mxwKOSh_E94nAlZ6hJvHABMcbkk8aT5cRaZReDJizCcyKHVDnotRXZxaw8uRBrFWJzLpBjS_7l8b';
  // String secret =
  //     'EIRhRLd2s8tNJtsMtgvgGa_E8kP7vPvEGI0K3xNlPpGvs9Skn_ICRdmCYkd3oBg-RW7YVFkNMF4575zI';

  // for live

  String clientId =
      'AQipoB0qgoe6NYLuXSfVIjYSgUzqRQEyx6n2fK3G9Zeb9OBpIyz7NJul1ht5eFo_vS8o1jjk0WBTdrwE';
  String secret =
      'EDGqFiAub728WRvDr_luTMg9yxwsbz31FdK97iBlQq9i1V_HN3DmW6b3cFW21GhwcCPF_mD2njxh5lr5';

  // for getting the access token from Paypal
  Future<String> getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secret);
      final res = await client.post(
          Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'));
      final resData = json.decode(res.body);
      print(res);
      print(resData);
      if (res.statusCode >= 400) {
        print('getAccessToken' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      return resData["access_token"];
    } catch (e) {
      print('getAccessToken' + e.toString());
      rethrow;
    }
  }

  // for create order
  Future<Map<String, String>?> createOrder(body, accessToken) async {
    try {
      final res = await http.post(Uri.parse("$domain/v2/checkout/orders"),
          body: jsonEncode(body),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final resData = json.decode(res.body);
      print(res.statusCode);
      if (res.statusCode >= 400) {
        print('createOrder' + resData.toString());
        return null;
      }
      if (resData["links"] != null && resData["links"].length > 0) {
        List links = resData["links"];

        String captureUrl = "";
        String approveUrl = "";
        final item = links.firstWhere((o) => o["rel"] == "approve",
            orElse: () => null);
        if (item != null) {
          approveUrl = item["href"];
        }
        final item1 = links.firstWhere((o) => o["rel"] == "capture",
            orElse: () => null);
        if (item1 != null) {
          captureUrl = item1["href"];
        }
        return {"captureUrl": captureUrl, "approveUrl": approveUrl};
      }
      return null;
    } catch (e) {
      print('createOrder' + e.toString());
      rethrow;
    }
  }

  // for executing the payment transaction
  Future<dynamic> executePayment(url, accessToken) async {
    try {
      final res = await http.post(Uri.parse(url),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final resData = json.decode(res.body);
      print(resData);
      print(res.statusCode);
      if (res.statusCode >= 400) {
        print('executePayment' + resData.toString());
        return null;
      }
      return resData;
    } catch (e) {
      print('executePayment' + e.toString());
      rethrow;
    }
  }
}
