import 'package:app/constants/strings.dart';
import 'package:app/models/request_withdrawals_model.dart';
import 'package:app/models/withdrawals_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/utils/date_time_format.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'loading_screen.dart';

class UserWithdrawalsScreen extends StatefulWidget {
  const UserWithdrawalsScreen({Key? key}) : super(key: key);

  @override
  _UserWithdrawalsScreenState createState() => _UserWithdrawalsScreenState();
}

class _UserWithdrawalsScreenState extends State<UserWithdrawalsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _amount = "0.00";
  String _email = "";
  bool _isWithdrawalsLoaded = false;
  bool _isWithdrawalRequestLoaded = false;
  bool _isLoading = false;
  List<WithdrawalsModel> _withdrawals = [];
  RequestWithdrawalsModel? _withdrawalRequest;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        final db = Provider.of<DatabaseProvider>(context, listen: false);
        RequestWithdrawalsModel request = RequestWithdrawalsModel(
          uId: db.uId,
          email: _email,
          date: {".sv": "timestamp"},
          amount: _amount,
        );
        await db.addWithdrawalRequest(request.toMap());

        setState(() {
          _isWithdrawalRequestLoaded = false;
        });
        getWithdrawalsRequests();
      } catch (error) {
        print(error.toString());
        showInfoAlertDialog(context, strings['unknown_error']!, true);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getWithdrawals() {
    Provider.of<DatabaseProvider>(context, listen: false)
        .getWithdrawals()
        .then((value) {
      setState(() {
        _withdrawals = value;
        _isWithdrawalsLoaded = true;
      });
    });
  }

  void getWithdrawalsRequests() {
    Provider.of<DatabaseProvider>(context, listen: false)
        .getWithdrawalRequest()
        .then((value) {
      setState(() {
        _withdrawalRequest = value;
        _isWithdrawalRequestLoaded = true;
      });
    });
  }

  @override
  void initState() {
    getWithdrawals();
    getWithdrawalsRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    DatabaseProvider db = Provider.of<DatabaseProvider>(context, listen: true);
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
            body: _isWithdrawalsLoaded && _isWithdrawalRequestLoaded
                ? Container(
                    height: size.height,
                    width: size.width,
                    margin: EdgeInsets.only(
                        top: size.height * .05, bottom: size.height * .02),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _withdrawalRequest == null
                              ? Container(
                                  height: size.height * .4,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: size.width * .1,
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IntrinsicHeight(
                                          child: TextFormField(
                                            minLines: 1,
                                            style: TextStyle(
                                                fontSize: size.width * 0.04),
                                            decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                  size.height * .02,
                                                  size.height * .02,
                                                  size.height * .01,
                                                  size.height * .02,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.email,
                                                  size: size.width * 0.04,
                                                  color: Colors.grey,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Colors.grey,
                                                        )),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide(
                                                      color: theme.themeAccent,
                                                    )),
                                                labelText: strings[
                                                    "form_paypal_email"]!),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            onSaved: (value) {
                                              setState(() {
                                                _email =
                                                    value!.replaceAll(" ", "");
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value
                                                      .replaceAll(" ", "")
                                                      .isEmpty ||
                                                  !value.contains("@") ||
                                                  value
                                                          .replaceAll(" ", "")
                                                          .length <
                                                      5) {
                                                return strings[
                                                    "form_email_validate"]!;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        VerticalSpace(
                                            size: size, percentage: 0.02),
                                        IntrinsicHeight(
                                          child: TextFormField(
                                            minLines: 1,
                                            style: TextStyle(
                                                fontSize: size.width * 0.04),
                                            decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
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
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Colors.grey,
                                                        )),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide(
                                                      color: theme.themeAccent,
                                                    )),
                                                labelText:
                                                    strings["form_amount"]!),
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              setState(() {
                                                _amount =
                                                    value!.replaceAll(" ", "");
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value
                                                      .replaceAll(" ", "")
                                                      .replaceAll(",", "")
                                                      .isEmpty) {
                                                return strings[
                                                    "form_amount_validate"]!;
                                              }
                                              String v = value
                                                  .replaceAll(" ", "")
                                                  .replaceAll(",", "");
                                              double amount = double.parse(v);
                                              double balance = double.parse(db
                                                  .balance
                                                  .firstWhere((element) =>
                                                      element.code == 'USD')
                                                  .value!);
                                              if (amount > balance) {
                                                return strings[
                                                    "insufficient_balance"]!;
                                              }
                                              if (amount < 10) {
                                                return strings[
                                                    "minimum_withdrawal"]!;
                                              }
                                              if (amount > 1000) {
                                                return strings[
                                                    "maximum_withdrawal"]!;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        VerticalSpace(
                                            size: size, percentage: 0.02),
                                        Text(strings['fee_not_included']!),
                                        VerticalSpace(
                                            size: size, percentage: 0.025),
                                        _isLoading
                                            ? const CircularProgressIndicator
                                                .adaptive()
                                            : Container(
                                                width: size.width,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * .07),
                                                child: ElevatedButton(
                                                    onPressed: () => _submit(),
                                                    child: Text(
                                                      strings[
                                                          'withdrawal_request']!,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    )),
                                              ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: size.width * .1),
                                  child: Text(
                                    strings['already_requested']!,
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                          VerticalSpace(size: size, percentage: 0.1),
                          if (_withdrawalRequest != null)
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * .02),
                              child: Text(
                                strings['current_withdrawal_request']!,
                                style: TextStyle(color: theme.themeAccent),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          if (_withdrawalRequest != null)
                            VerticalSpace(size: size, percentage: 0.01),
                          if (_withdrawalRequest != null)
                            Container(
                                alignment: Alignment.center,
                                height: size.height * .1,
                                margin: EdgeInsets.symmetric(
                                    horizontal: size.width * .02),
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: theme.themeAccent,
                                            width: size.height * .0005),
                                        bottom: BorderSide(
                                            color: theme.themeAccent,
                                            width: size.height * .0005))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _withdrawalRequest!.email!,
                                          style: TextStyle(
                                              fontSize: size.width * .04),
                                        ),
                                        VerticalSpace(
                                            size: size, percentage: 0.01),
                                        Text(
                                          formatDateTime(
                                              _withdrawalRequest!.date!),
                                          style: TextStyle(
                                              fontSize: size.width * .04),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _withdrawalRequest!.amount! + " \$",
                                      style:
                                          TextStyle(fontSize: size.width * .04),
                                    )
                                  ],
                                )),
                          VerticalSpace(size: size, percentage: 0.04),
                          if (_withdrawals.isNotEmpty)
                            Container(
                              margin: EdgeInsets.all(size.width*.02),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                strings['previous_withdrawals']!,
                                style: TextStyle(
                                  color: theme.themeAccent,
                                  fontSize: size.width * .04,
                                ),
                              ),
                            ),
                          if (_withdrawals.isNotEmpty)
                            Container(
                              alignment: Alignment.topCenter,
                              height: size.height * .3,
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * .02),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _withdrawals.length,
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
                                                _withdrawals[i].id!,
                                                style: TextStyle(
                                                    fontSize: size.width * .04),
                                              ),
                                              VerticalSpace(
                                                  size: size, percentage: 0.01),
                                              Text(
                                                _withdrawals[i].email!,
                                                style: TextStyle(
                                                    fontSize: size.width * .04),
                                              ),
                                              VerticalSpace(
                                                  size: size, percentage: 0.01),
                                              Text(
                                                formatDateTime(
                                                    _withdrawals[i].date!),
                                                style: TextStyle(
                                                    fontSize: size.width * .04),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            _withdrawals[i].amount! + " \$",
                                            style: TextStyle(
                                                fontSize: size.width * .04),
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
