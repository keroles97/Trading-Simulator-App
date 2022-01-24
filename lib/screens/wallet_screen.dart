import 'package:app/constants/strings.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/user_deposits_screen.dart';
import 'package:app/screens/user_withdrawals_screen.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loading_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isDataLoaded = false;

  void getUserBalance() {
    Provider.of<DatabaseProvider>(context, listen: false)
        .getUserBalance()
        .then((value) {
      setState(() {
        _isDataLoaded = true;
      });
    });
  }

  @override
  initState() {
    getUserBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    DatabaseProvider db = Provider.of<DatabaseProvider>(context, listen: true);
    return SizedBox(
        height: size.height,
        width: size.width,
        child: _isDataLoaded
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VerticalSpace(size: size, percentage: 0.01),
                    Text(
                      strings['my_wallet']!,
                      style: TextStyle(
                          color: theme.themeAccent,
                          fontSize: size.width * .05),
                    ),
                    VerticalSpace(size: size, percentage: 0.03),
                    Text(
                      strings['usd_balance']!,
                      style: TextStyle(
                          color: theme.themeAccent, fontSize: size.width * .04),
                    ),
                    VerticalSpace(size: size, percentage: 0.01),
                    Text(
                      db.balance
                          .singleWhere((element) => element.code == 'USD')
                          .value!,
                      style: TextStyle(fontSize: size.width * .04),
                    ),
                    VerticalSpace(size: size, percentage: 0.05),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * .02),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        strings['other_currencies_balance']!,
                        style: TextStyle(
                            color: theme.themeAccent,
                            fontSize: size.width * .04
                        ),
                      ),
                    ),
                    VerticalSpace(size: size, percentage: 0.02),
                    Container(
                      alignment: Alignment.topCenter,
                      height: size.height * .36,
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * .02),
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: theme.themeAccent,
                                  width: size.height * .0005))),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: db.balance.length,
                          itemBuilder: (ctx, i) {
                            return Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * .04),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: theme.themeAccent,
                                          width: size.height * .0005))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    db.balance[i].code!,
                                    style:
                                        TextStyle(fontSize: size.width * .04),
                                  ),
                                  Text(
                                    db.balance[i].value!,
                                    style:
                                        TextStyle(fontSize: size.width * .04),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                    VerticalSpace(size: size, percentage: 0.03),
                    Container(
                      width: size.width,
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * .15),
                      child: ElevatedButton(
                          onPressed: () async {
                            var result = await Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) {
                              return const UserWithdrawalsScreen();
                            }));
                            setState(() {
                              _isDataLoaded = false;
                              getUserBalance();
                            });
                          },
                          child: Text(
                            strings['withdrawal']!,
                            style: const TextStyle(color: Colors.white),
                          )),
                    ),
                    VerticalSpace(size: size, percentage: 0.005),
                    Container(
                      width: size.width,
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * .15),
                      child: ElevatedButton(
                          onPressed: () async {
                            var result = await Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) {
                              return const UserDepositsScreen();
                            }));
                            setState(() {
                              _isDataLoaded = false;
                              getUserBalance();
                            });
                          },
                          child: Text(
                            strings['deposit']!,
                            style: const TextStyle(color: Colors.white),
                          )),
                    )
                  ],
                ),
              )
            : const LoadingScreen());
  }
}
