import 'dart:convert';

import 'package:app/models/currency_model.dart';
import 'package:app/models/deposits_model.dart';
import 'package:app/models/http_exception_model.dart';
import 'package:app/models/in_process_request_model.dart';
import 'package:app/models/notification_model.dart';
import 'package:app/models/request_withdrawals_model.dart';
import 'package:app/models/selling_buying_model.dart';
import 'package:app/models/withdrawals_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DatabaseProvider with ChangeNotifier {
  String? _token;
  String? _uId;
  String? name;
  String? email;
  List<CurrencyModel> _balance = [];
  int unreadNotificationCount = 0;
  int unreadMessagesCount = 0;

  String? get uId => _uId;

  String? get token => _token;

  List<CurrencyModel> get balance => _balance;

  getUserAuthData(String? token, String? uId) async {
    _token = token;
    _uId = uId;
  }

  String databaseApi(String path) {
    return 'https://crypto-currency-6c754-default-rtdb.firebaseio.com/$path.json?auth=$token';
  }

  Future<List<CurrencyModel>> getSpecialCurrencies() async {
    try {
      final res = await http.get(Uri.parse(databaseApi('specialCurrencies')));
      final resData = json.decode(res.body);
      List<CurrencyModel> log = [];

      if (res.statusCode >= 400) {
        print('getSpecialCurrencies' + resData['error'].toString());
        return log;
      }
      if (resData == null) {
        return log;
      }
      for (var e in resData.values) {
        log.add(CurrencyModel.fromJson(Map<String, dynamic>.from(e)));
      }
      return log;
    } catch (e) {
      print('getSpecialCurrencies' + e.toString());
      rethrow;
    }
  }

  Future<void> set(String path, Object data) async {
    try {
      final res =
          await http.put(Uri.parse(databaseApi(path)), body: json.encode(data));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('set' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      print('set' + e.toString());
      rethrow;
    }
  }

  Future<void> addUserData(String path, Object data) async {
    try {
      final res =
          await http.put(Uri.parse(databaseApi(path)), body: json.encode(data));
      final resData = json.decode(res.body);
      _token = null;
      _uId = null;
      if (res.statusCode >= 400) {
        print('addUserData' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      print('addUserData' + e.toString());
      rethrow;
    }
  }

  Future<void> getUserData() async {
    try {
      await set('users/$uId/token', token!);

      final res = await http.get(Uri.parse(databaseApi('users/$uId')));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('getUserData' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      name = resData['name'];
      email = resData['email'];
    } catch (e) {
      print('getUserData' + e.toString());
      rethrow;
    }
  }

  Future<void> getUserBalance() async {
    try {
      _balance.clear();
      final res = await http.get(Uri.parse(databaseApi('userBalance/$uId')));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('getUserBalance' + resData['error'].toString());
        _balance.add(CurrencyModel(code: 'USD', value: '0.00'));
        throw HttpException(resData['error']['message']);
      }
      if (resData != null) {
        Map<String, dynamic> balance = resData as Map<String, dynamic>;
        balance.forEach((key, value) {
          _balance
              .add(CurrencyModel(code: key, value: (value + 00.00).toString()));
        });
      } else {
        _balance.add(CurrencyModel(code: 'USD', value: '0.00'));
      }
      notifyListeners();
    } catch (e) {
      print('getUserBalance' + e.toString());
      rethrow;
    }
  }

  Future<void> setUserBalance(String currency, double amount) async {
    try {
      final res =
          await http.put(Uri.parse(databaseApi('userBalance/$uId/$currency')),
              body: json.encode({
                ".sv": {"increment": amount}
              }));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('set' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      print('set' + e.toString());
      rethrow;
    }
  }

  Future<List<DepositsModel>> getDeposits() async {
    try {
      final res = await http.get(Uri.parse(databaseApi('deposits/$uId')));
      final resData = json.decode(res.body);
      List<DepositsModel> log = [];

      if (res.statusCode >= 400) {
        print('getDeposits' + resData['error'].toString());
        return log;
      }
      if (resData == null) {
        return log;
      }
      for (var e in resData.values) {
        log.add(DepositsModel.fromJson(Map<String, dynamic>.from(e)));
      }
      log.sort((a, b) => double.parse(b.date!.toString())
          .compareTo(double.parse(a.date!.toString())));
      return log;
    } catch (e) {
      print('getDeposits' + e.toString());
      rethrow;
    }
  }

  Future<void> addDepositData(String id, Object data) async {
    try {
      final res = await http.put(Uri.parse(databaseApi("deposits/$uId/$id")),
          body: json.encode(data));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('addDepositData' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      print('addDepositData' + e.toString());
      rethrow;
    }
  }

  Future<List<WithdrawalsModel>> getWithdrawals() async {
    try {
      final res = await http.get(Uri.parse(databaseApi('withdrawals/$uId')));
      final resData = json.decode(res.body);
      List<WithdrawalsModel> log = [];

      if (res.statusCode >= 400) {
        print('getWithdrawals' + resData['error'].toString());
        return log;
      }
      if (resData == null) {
        return log;
      }
      for (var e in resData.values) {
        log.add(WithdrawalsModel.fromJson(Map<String, dynamic>.from(e)));
      }
      log.sort((a, b) => double.parse(b.date!.toString())
          .compareTo(double.parse(a.date!.toString())));
      return log;
    } catch (e) {
      print('getWithdrawals' + e.toString());
      rethrow;
    }
  }

  Future<RequestWithdrawalsModel?> getWithdrawalRequest() async {
    try {
      final res =
          await http.get(Uri.parse(databaseApi('withdrawalsRequests/$uId')));
      final resData = json.decode(res.body);
      RequestWithdrawalsModel request;

      if (res.statusCode >= 400) {
        print('getWithdrawalsRequests' + resData['error'].toString());
        return null;
      }
      if (resData == null) {
        return null;
      }
      request =
          RequestWithdrawalsModel.fromJson(Map<String, dynamic>.from(resData));
      return request;
    } catch (e) {
      print('getWithdrawalsRequests' + e.toString());
      rethrow;
    }
  }

  Future<void> addWithdrawalRequest(Object data) async {
    try {
      final res = await http.put(
          Uri.parse(databaseApi("withdrawalsRequests/$uId")),
          body: json.encode(data));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('addWithdrawalRequest' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      print('addWithdrawalRequest' + e.toString());
      rethrow;
    }
  }

  Future<void> getNotificationsUnreadCount() async {
    try {
      final res = await http
          .get(Uri.parse(databaseApi('notifications/$uId/unreadCount')));
      final resData = json.decode(res.body);

      if (res.statusCode >= 400) {
        print('getNotificationsUnreadCount' + resData['error'].toString());
        return;
      }
      if (resData == null) {
        return;
      }
      unreadNotificationCount = resData;
      notifyListeners();
    } catch (e) {
      print('getNotificationsUnreadCount' + e.toString());
      rethrow;
    }
  }

  Future<void> setNotificationsUnreadCount() async {
    try {
      final res = await http.patch(Uri.parse(databaseApi('notifications/$uId')),
          body: json.encode({'unreadCount': 0}));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('setNotificationsUnreadCount' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      unreadNotificationCount = 0;
    } catch (e) {
      print('setNotificationsUnreadCount' + e.toString());
      rethrow;
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res =
          await http.get(Uri.parse(databaseApi('notifications/$uId/alerts')));
      final resData = json.decode(res.body);
      List<NotificationModel> log = [];

      if (res.statusCode >= 400) {
        print('getNotifications' + resData['error'].toString());
        return log;
      }
      if (resData == null) {
        return log;
      }
      for (var e in resData.values) {
        log.add(NotificationModel.fromJson(Map<String, dynamic>.from(e)));
      }
      log.sort((a, b) => double.parse(b.date!.toString())
          .compareTo(double.parse(a.date!.toString())));
      return log;
    } catch (e) {
      print('getNotifications' + e.toString());
      rethrow;
    }
  }

  Future<void> sendMessage(data) async {
    try {
      final res = await http.post(Uri.parse(databaseApi('chats/$uId/messages')),
          body: json.encode(data));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('sendMessage' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      await setMessagesSupportUnreadCount(1);
    } catch (e) {
      print('sendMessage' + e.toString());
      rethrow;
    }
  }

  Future<void> getMessagesUnreadCount() async {
    try {
      final res =
          await http.get(Uri.parse(databaseApi('chats/$uId/userUnreadCount')));
      final resData = json.decode(res.body);

      if (res.statusCode >= 400) {
        print('getMessagesUnreadCount' + resData['error'].toString());
        return;
      }
      if (resData == null) {
        return;
      }
      unreadMessagesCount = resData;
      notifyListeners();
    } catch (e) {
      print('getMessagesUnreadCount' + e.toString());
      rethrow;
    }
  }

  Future<void> setMessagesUserUnreadCount() async {
    try {
      final res = await http.patch(Uri.parse(databaseApi('chats/$uId')),
          body: json.encode({'userUnreadCount': 0}));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('setMessagesUserUnreadCount' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      unreadMessagesCount = 0;
    } catch (e) {
      print('setMessagesUserUnreadCount' + e.toString());
      rethrow;
    }
  }

  Future<void> setMessagesSupportUnreadCount(count) async {
    try {
      final res = await http.put(Uri.parse(databaseApi('supportChatList/$uId')),
          body: json.encode({
            "uId": uId,
            "email": email,
            "name": name,
            "supportUnreadCount": {
              ".sv": {"increment": count}
            },
            "date": {".sv": "timestamp"}
          }));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('setMessagesSupportUnreadCount' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      print('setMessagesSupportUnreadCount' + e.toString());
      rethrow;
    }
  }

  Future<List<SellingBuyingModel>> getBuyingRequests() async {
    try {
      final res = await http.get(Uri.parse(databaseApi('buyingRequests')));
      final resData = json.decode(res.body);
      List<SellingBuyingModel> log = [];

      if (res.statusCode >= 400) {
        print('getBuyingRequests' + resData['error'].toString());
        return log;
      }
      if (resData == null) {
        return log;
      }
      for (var e in resData.values) {
        log.add(SellingBuyingModel.fromJson(Map<String, dynamic>.from(e)));
      }
      log.sort((a, b) => double.parse(b.date!.toString())
          .compareTo(double.parse(a.date!.toString())));
      return log;
    } catch (e) {
      print('getBuyingRequests' + e.toString());
      rethrow;
    }
  }

  Future<List<SellingBuyingModel>> getSellingRequests() async {
    try {
      final res = await http.get(Uri.parse(databaseApi('sellingRequests')));
      final resData = json.decode(res.body);
      List<SellingBuyingModel> log = [];

      if (res.statusCode >= 400) {
        print('getSellingRequests' + resData['error'].toString());
        return log;
      }
      if (resData == null) {
        return log;
      }
      for (var e in resData.values) {
        log.add(SellingBuyingModel.fromJson(Map<String, dynamic>.from(e)));
      }
      log.sort((a, b) => double.parse(b.date!.toString())
          .compareTo(double.parse(a.date!.toString())));
      return log;
    } catch (e) {
      print('getSellingRequests' + e.toString());
      rethrow;
    }
  }

  Future<List<InProcessRequestModel>> getInProcessRequests() async {
    try {
      final res = await http.get(Uri.parse(databaseApi('inProcessRequests')));
      final resData = json.decode(res.body);
      List<InProcessRequestModel> log = [];

      if (res.statusCode >= 400) {
        print('getInProcessRequests' + resData['error'].toString());
        return log;
      }
      if (resData == null) {
        return log;
      }
      for (var e in resData.values) {
        log.add(InProcessRequestModel.fromJson(Map<String, dynamic>.from(e)));
      }
      log.sort((a, b) => double.parse(b.date!.toString())
          .compareTo(double.parse(a.date!.toString())));
      return log;
    } catch (e) {
      print('getInProcessRequests' + e.toString());
      rethrow;
    }
  }

  Future<List<InProcessRequestModel>> getCompletedRequests() async {
    try {
      final res =
          await http.get(Uri.parse(databaseApi('completedRequests/$uId')));
      final resData = json.decode(res.body);
      List<InProcessRequestModel> log = [];

      if (res.statusCode >= 400) {
        print('getCompletedRequests' + resData['error'].toString());
        return log;
      }
      if (resData == null) {
        return log;
      }
      for (var e in resData.values) {
        log.add(InProcessRequestModel.fromJson(Map<String, dynamic>.from(e)));
      }
      log.sort((a, b) => double.parse(b.date!.toString())
          .compareTo(double.parse(a.date!.toString())));
      return log;
    } catch (e) {
      print('getCompletedRequests' + e.toString());
      rethrow;
    }
  }

  Future<void> addBuyingSellingRequest(String path, Object data) async {
    try {
      final res = await http.post(Uri.parse(databaseApi(path)),
          body: json.encode(data));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('addBuyingSellingRequest' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      await set('$path/${resData['name']}/id', resData['name'].toString());
    } catch (e) {
      print('addBuyingSellingRequest' + e.toString());
      rethrow;
    }
  }

  Future<void> deleteBuyingSellingRequest(String path) async {
    try {
      final res = await http.delete(Uri.parse(databaseApi(path)));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('deleteBuyingSellingRequest' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      print('deleteBuyingSellingRequest' + e.toString());
      rethrow;
    }
  }

  Future<void> addInProcessingRequest(String path, Object data) async {
    try {
      final res =
          await http.put(Uri.parse(databaseApi(path)), body: json.encode(data));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        print('addInProcessingRequest' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      print('addInProcessingRequest' + e.toString());
      rethrow;
    }
  }
}
