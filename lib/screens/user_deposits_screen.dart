import 'package:app/constants/strings.dart';
import 'package:app/models/deposits_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/paypal_payment_screen.dart';
import 'package:app/utils/date_time_format.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loading_screen.dart';

class UserDepositsScreen extends StatefulWidget {
  const UserDepositsScreen({Key? key}) : super(key: key);

  @override
  _UserDepositsScreenState createState() => _UserDepositsScreenState();
}

class _UserDepositsScreenState extends State<UserDepositsScreen> {
  final _formKey = GlobalKey<FormState>();
  double _amountMinusFee = 0.00;
  String _amount = "0.00";
  bool _isDepositsLoaded = false;
  List<DepositsModel> _deposits = [];

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      var result =
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return PaypalPaymentScreen(
          amount: _amount,
          amountMinusFee: _amountMinusFee,
        );
      }));
      if (result != null && result) {
        print(result);
        setState(() {
          _isDepositsLoaded = false;
          _amountMinusFee = 0.00;
          _amount = "0.00";
        });
        getDeposits();
      }
    }
  }

  void getDeposits() {
    Provider.of<DatabaseProvider>(context, listen: false)
        .getDeposits()
        .then((value) {
      setState(() {
        _deposits = value;
        _isDepositsLoaded = true;
      });
    });
  }

  @override
  void initState() {
    getDeposits();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
            body: _isDepositsLoaded
                ? Container(
                    height: size.height,
                    width: size.width,
                    margin: EdgeInsets.symmetric(vertical: size.height * .05),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: size.width * .1,
                            ),
                            child: Form(
                              key: _formKey,
                              child: IntrinsicHeight(
                                child: TextFormField(
                                  minLines: 1,
                                  style: TextStyle(fontSize: size.width * 0.04),
                                  decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.fromLTRB(
                                        size.height * .02,
                                        size.height * .02,
                                        size.height * .01,
                                        size.height * .02,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.attach_money,
                                        size: size.width * 0.04,
                                        color: Colors.grey,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: Colors.grey,
                                          )),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: theme.themeAccent,
                                          )),
                                      labelText: strings["form_amount"]!),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    String? v = value
                                        .replaceAll(" ", "")
                                        .replaceAll(",", "");
                                    if (v != null && v.isNotEmpty) {
                                      setState(() {
                                        double a = double.parse(v);
                                        double fee = ((a * 3) / 100) + .30;
                                        _amountMinusFee = double.parse(
                                            (a - fee).toStringAsFixed(2));
                                        _amount = (a).toStringAsFixed(2);
                                      });
                                    } else {
                                      setState(() {
                                        _amountMinusFee = 0.00;
                                        _amount = "0.00";
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return strings["form_amount_validate"]!;
                                    }
                                    if (value
                                        .replaceAll(" ", "")
                                        .replaceAll(",", "")
                                        .isEmpty) {
                                      return strings["form_amount_validate"]!;
                                    }
                                    String v = value
                                        .replaceAll(" ", "")
                                        .replaceAll(",", "");
                                    double amount = double.parse(v);
                                    if (amount < 5) {
                                      return strings["minimum_deposit"]!;
                                    }
                                    if (amount > 1000) {
                                      return strings["maximum_deposit"]!;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          VerticalSpace(size: size, percentage: 0.02),
                          Text("credited to your balance: $_amountMinusFee \$"),
                          VerticalSpace(size: size, percentage: 0.025),
                          Container(
                            width: size.width,
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * .17),
                            child: ElevatedButton(
                                onPressed: () => _submit(),
                                child: Text(
                                  strings['deposit']!,
                                  style: const TextStyle(color: Colors.white),
                                )),
                          ),
                          VerticalSpace(size: size, percentage: 0.1),
                          Container(
                            margin: EdgeInsets.all(size.width*.02),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              strings['deposit_history']!,
                              style: TextStyle(
                                color: theme.themeAccent,
                                fontSize: size.width * .04,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            height: size.height * .54,
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * .02),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _deposits.length,
                                itemBuilder: (ctx, i) {
                                  return Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.width * .04),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: theme.themeAccent,
                                                width: size.height * .0005),
                                            top: BorderSide(
                                                color: theme.themeAccent,
                                                width: size.height * .0005))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _deposits[i].id!,
                                              style: TextStyle(
                                                  fontSize: size.width * .04),
                                            ),
                                            VerticalSpace(
                                                size: size, percentage: 0.01),
                                            Text(
                                              formatDateTime(
                                                  _deposits[i].date!),
                                              style: TextStyle(
                                                  fontSize: size.width * .04),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _deposits[i].amount! + " \$",
                                              style: TextStyle(
                                                  fontSize: size.width * .04),
                                            ),
                                            VerticalSpace(
                                                size: size, percentage: 0.01),
                                            Text(
                                              _deposits[i].amountMinusFee! +
                                                  " \$",
                                              style: TextStyle(
                                                  fontSize: size.width * .04),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  )
                : const LoadingScreen()),
      ),
    );
  }
}
