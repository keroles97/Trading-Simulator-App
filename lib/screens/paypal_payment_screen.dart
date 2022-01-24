import 'dart:io';

import 'package:app/models/deposits_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/screens/loading_screen.dart';
import 'package:app/services/paypal_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalPaymentScreen extends StatefulWidget {
  const PaypalPaymentScreen(
      {Key? key, required this.amount, required this.amountMinusFee})
      : super(key: key);

  final String amount;
  final double amountMinusFee;

  @override
  _PaypalPaymentScreenState createState() => _PaypalPaymentScreenState();
}

class _PaypalPaymentScreenState extends State<PaypalPaymentScreen> {
  String? _checkoutUrl;
  String? _executeUrl;
  String? _accessToken;
  PaypalServices services = PaypalServices();
  bool _isLoading = true;

  String returnURL = 'https://return.example.com';
  String cancelURL = 'https://cancel.example.com';

  Future<void> deposit(BuildContext context) async {
    try {
      _accessToken = await services.getAccessToken();

      final body = getOrderParams();
      final res = await services.createOrder(body, _accessToken);
      if (res == null) {
        Navigator.of(context).pop(false);
        return;
      }
      setState(() {
        _checkoutUrl = res["approveUrl"]!;
        _executeUrl = res["captureUrl"]!;
        _isLoading = false;
      });
    } catch (e) {
      print('exception: ' + e.toString());
      Navigator.of(context).pop(false);
    }
  }

  Map<String, dynamic> getOrderParams() {
    return {
      "intent": "CAPTURE",
      "purchase_units": [
        {
          "amount": {"currency_code": "USD", "value": widget.amount}
        }
      ],
      "application_context": {"return_url": returnURL, "cancel_url": cancelURL}
    };
  }

  Future<void> executeDeposit(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final res = await services.executePayment(_executeUrl, _accessToken);
      if (res == null) {
        Navigator.of(context).pop(false);
        return;
      }
      var opStatus = res['status'];
      var opId = res['purchase_units'][0]['payments']['captures'][0]['id'];
      var payStatus =
          res['purchase_units'][0]['payments']['captures'][0]['status'];
      if (opStatus == "COMPLETED" && payStatus == "COMPLETED") {
        DepositsModel operation = DepositsModel(
          id: opId,
          date: {".sv": "timestamp"},
          amount: widget.amount.toString(),
          amountMinusFee: widget.amountMinusFee.toString(),
        );
        await Provider.of<DatabaseProvider>(context, listen: false)
            .setUserBalance('USD', widget.amountMinusFee);
        await Provider.of<DatabaseProvider>(context, listen: false)
            .addDepositData(opId, operation.toMap());
        Navigator.of(context).pop(true);
        return;
      }
      Navigator.of(context).pop(false);
    } catch (error) {
      print(error.toString());
      Navigator.of(context).pop(false);
    }
  }

  @override
  void initState() {
    super.initState();
    deposit(context);
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: _isLoading
              ? const LoadingScreen()
              : WebView(
                  initialUrl: _checkoutUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  navigationDelegate: (NavigationRequest request) async {
                    if (request.url.contains(returnURL)) {
                      executeDeposit(context);
                    }
                    if (request.url.contains(cancelURL)) {
                      Navigator.of(context).pop(false);
                    }
                    return NavigationDecision.navigate;
                  },
                ),
        ),
      ),
    );
  }
}
