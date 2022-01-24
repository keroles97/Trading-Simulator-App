import 'package:app/constants/strings.dart';
import 'package:app/models/selling_buying_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/exchange_rate_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBuyingRequestScreen extends StatefulWidget {
  const AddBuyingRequestScreen({Key? key}) : super(key: key);

  @override
  _AddBuyingRequestScreenState createState() => _AddBuyingRequestScreenState();
}

class _AddBuyingRequestScreenState extends State<AddBuyingRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currency = "USD";
  int _amount = 1;
  double _pricePerCoin = 0.00;
  String _totalPrice = "";
  bool _isLoading = false;

  void _submit() async {
    FocusScope.of(context).unfocus();
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      try {
        _formKey.currentState!.save();
        setState(() {
          _isLoading = true;
          _totalPrice = ((_amount * _pricePerCoin) + 0.00).toString();
        });
        SellingBuyingModel data = SellingBuyingModel(
            id: '',
            sellerUId: '',
            buyerUId: db.uId,
            currency: _currency,
            amount: _amount.toString(),
            pricePerCoin: _pricePerCoin.toString(),
            totalPrice: _totalPrice,
            date: {".sv": "timestamp"});
        await db.addBuyingSellingRequest('buyingRequests', data.toMap());
        Navigator.of(context).pop(true);
      } catch (error) {
        print(error.toString());
        showInfoAlertDialog(context, strings['unknown_error']!, true);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _currency = Provider.of<ExchangeRateProvider>(context, listen: false)
        .currenciesAndSpecialCurrencies[0];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    DatabaseProvider db = Provider.of<DatabaseProvider>(context, listen: true);
    ExchangeRateProvider exr =
        Provider.of<ExchangeRateProvider>(context, listen: false);
    return SafeArea(
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: Container(
                width: size.width,
                height: size.height,
                margin: EdgeInsets.symmetric(
                    horizontal: size.width * .1, vertical: size.height * .01),
                child: SingleChildScrollView(
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VerticalSpace(size: size, percentage: 0.03),
                          Text(
                            strings['buying_request']!,
                            style: TextStyle(
                                color: theme.themeAccent,
                                fontSize: size.width * .04),
                          ),
                          VerticalSpace(size: size, percentage: 0.03),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: theme.themeAccent)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                style: TextStyle(fontSize: size.width * 0.04),
                                iconEnabledColor: theme.swapBackground(),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                alignment: Alignment.center,
                                isExpanded: true,
                                value: _currency,
                                items: exr.currenciesAndSpecialCurrencies
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    alignment: Alignment.center,
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          color: theme.swapBackground()),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _currency = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          VerticalSpace(size: size, percentage: 0.02),
                          IntrinsicHeight(
                            child: TextFormField(
                              initialValue: _amount.toString(),
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
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      )),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: theme.themeAccent,
                                      )),
                                  labelText: strings["form_amount"]!),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  if (value.isNotEmpty) {
                                    _amount = int.parse(value
                                        .replaceAll(" ", "")
                                        .replaceAll(',', ''));
                                    _totalPrice =
                                        ((_amount * _pricePerCoin) + 0.00)
                                            .toString();
                                  } else {
                                    _amount = 0;
                                    _totalPrice = "0.00";
                                  }
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _amount = int.parse(value!
                                      .replaceAll(" ", "")
                                      .replaceAll(',', ''));
                                });
                              },
                              validator: (value) {
                                if (value == null ||
                                    value
                                        .replaceAll(" ", "")
                                        .replaceAll(",", "")
                                        .isEmpty) {
                                  return strings["form_amount_validate"]!;
                                }
                                return null;
                              },
                            ),
                          ),
                          VerticalSpace(size: size, percentage: 0.02),
                          IntrinsicHeight(
                            child: TextFormField(
                              initialValue: _pricePerCoin.toString(),
                              maxLines: 1,
                              style: TextStyle(fontSize: size.width * 0.04),
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    size.height * .02,
                                    size.height * .02,
                                    size.height * .01,
                                    size.height * .02,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      )),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: theme.themeAccent,
                                      )),
                                  labelText: strings["form_price_per_coin"]!),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  if (value.isNotEmpty) {
                                    _pricePerCoin =
                                        double.parse(value.replaceAll(" ", ""));
                                    _totalPrice =
                                        ((_amount * _pricePerCoin) + 0.00)
                                            .toString();
                                  } else {
                                    _pricePerCoin = 0.00;
                                    _totalPrice = "0.00";
                                  }
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _pricePerCoin =
                                      double.parse(value!.replaceAll(" ", ""));
                                });
                              },
                              validator: (value) {
                                double? val = double.tryParse(
                                    value.toString().replaceAll(" ", ""));
                                if (val == null) {
                                  return strings[
                                      "form_price_per_coin_validate"]!;
                                }
                                String? code;
                                try {
                                  code = db.balance
                                      .firstWhere(
                                          (element) => element.code == 'USD')
                                      .value!;
                                } catch (_) {}
                                if (code == null) {
                                  return strings["insufficient_balance"]!;
                                }
                                double? balance = double.tryParse(code);
                                if (balance == null ||
                                    double.parse(_totalPrice) > balance) {
                                  return strings["insufficient_balance"]!;
                                }
                                return null;
                              },
                            ),
                          ),
                          VerticalSpace(size: size, percentage: 0.02),
                          Text(
                            strings['fees_not_includes']!,
                            style: TextStyle(
                                fontSize: size.height * .025,
                                color: theme.themeAccent),
                          ),
                          VerticalSpace(size: size, percentage: 0.04),
                          Text(
                            strings['total_price']!,
                            style: TextStyle(
                                fontSize: size.height * .025,
                                color: theme.themeAccent),
                          ),
                          VerticalSpace(size: size, percentage: 0.01),
                          Text(
                            ((_amount * _pricePerCoin) + 0.00).toString(),
                            style: TextStyle(
                                fontSize: size.height * .025,
                                color: Colors.white),
                          ),
                          VerticalSpace(size: size, percentage: 0.02),
                          _isLoading
                              ? const CircularProgressIndicator.adaptive()
                              : Container(
                                  width: size.width,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: size.width * .1, vertical: 0),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.symmetric(
                                                vertical: size.height * .01)),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                      ),
                                      onPressed: () => _submit(),
                                      child: Text(
                                        strings["publish"]!,
                                        style: TextStyle(
                                            fontSize: size.height * .025,
                                            color: Colors.white),
                                      )),
                                ),
                        ],
                      )),
                ),
              ),
            )));
  }
}
