import 'dart:convert';

import 'package:app/models/currency_historical_rate_model.dart';
import 'package:app/models/currency_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ExchangeRateProvider with ChangeNotifier {
  List<CurrencyModel> rates = [];
  List<String> currencies = [];
  List<String> currenciesAndSpecialCurrencies = [];

  String _exchangeRateApi(String urlSegment) {
    return 'https://api.exchangerate.host/$urlSegment';
  }

  Future<void> getExchangeRates(
      List<CurrencyModel> list, String sortType) async {
    try {
      this.rates.clear();
      final res =
          await http.get(Uri.parse(_exchangeRateApi('latest?base=USD')));
      if (res.statusCode >= 400) {
        print('failed: getExchangeRates');
        return;
      }
      final resData = json.decode(res.body);
      Map<String, dynamic> rates = resData['rates'] as Map<String, dynamic>;
      rates.forEach((key, value) {
        this.rates.add(CurrencyModel(code: key, value: value.toString()));
      });
      if (currencies.isEmpty) {
        for (var e in this.rates) {
          currencies.add(e.code!);
        }
        currencies.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }

      this.rates.addAll(list);

      if (currenciesAndSpecialCurrencies.isEmpty) {
        for (var e in this.rates) {
          currenciesAndSpecialCurrencies.add(e.code!);
        }
        currenciesAndSpecialCurrencies
            .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }
      sort(sortType);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CurrencyHistoricalRateModel>>? dailyHistoricalRate(
      String currency) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime old = DateTime(now.year - 1, now.month, now.day);
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String endDate = formatter.format(now);
      final String startDate = formatter.format(old);

      final res = await http.get(Uri.parse(_exchangeRateApi(
          'timeseries?start_date=$startDate&end_date=$endDate&base=USD&symbols=$currency')));
      List<CurrencyHistoricalRateModel> list = [];
      if (res.statusCode >= 400) {
        print('failed: dailyHistoricalRate: ${res.statusCode}');
        return [];
      }
      final resData = json.decode(res.body);
      print(res.statusCode);
      print(resData);
      Map<String, dynamic> rates = resData['rates'] as Map<String, dynamic>;
      rates.forEach((key, value) {
        list.add(CurrencyHistoricalRateModel(
            DateTime.parse(key), value[currency] + 0.0));
      });
      return list;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<double> convert(String from, String to, double amount) async {
    try {
      final res = await http.get(Uri.parse(
          _exchangeRateApi('convert?from=$from&to=$to&amount=$amount')));
      if (res.statusCode >= 400) {
        print('failed: convert');
        return 0.0;
      }
      final resData = json.decode(res.body);
      return resData['result'] + 0.0;
    } catch (e) {
      rethrow;
    }
  }

  void sort(String type) {
    try {
      switch (type) {
        case 'Alphabetically':
          return rates.sort(
              (a, b) => a.code!.toLowerCase().compareTo(b.code!.toLowerCase()));
        case 'Price Ascending':
          return rates.sort((a, b) => a.value!.compareTo(b.value!));
        case 'Price Descending':
          return rates.sort((b, a) => a.value!.compareTo(b.value!));
        default:
          return rates.sort(
              (a, b) => a.code!.toLowerCase().compareTo(b.code!.toLowerCase()));
      }
    } finally {
      notifyListeners();
    }
  }
}
