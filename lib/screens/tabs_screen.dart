import 'package:app/constants/strings.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/exchange_rate_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/buying_and_selling_requests_tab_screen.dart';
import 'package:app/screens/exchange_rate_tab_screen.dart';
import 'package:app/screens/settings_tab_screen.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'account_tab_screen.dart';
import 'loading_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  bool _userDataLoaded = false;
  int _selectedPageIndex = 0;
  final TextEditingController _amountController = TextEditingController();
  String _convertFrom = 'BTC';
  String _convertTo = 'USD';
  double _convertResult = 0.0;
  bool _isConverting = false;

  Future<void> _convert(StateSetter setState) async {
    try {
      setState(() {
        _isConverting = true;
      });
      _convertResult = await Provider.of<ExchangeRateProvider>(context,
              listen: false)
          .convert(
              _convertFrom, _convertTo, double.parse(_amountController.text));
    } catch (error) {
      print(error);
      showInfoAlertDialog(context, strings['unknown_error']!, true);
    }
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isConverting = false;
    });
  }

  final List<Widget> _screen = [
    const ExchangeRateTabScreen(),
    const BuyingAndSellingRequestsTabScreen(),
    const AccountTabScreen(),
    const SettingsTabScreen(),
  ];

  void _handleNavigationTap(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  void initState() {
    FirebaseMessaging.instance.subscribeToTopic('AppAlerts');

    Provider.of<DatabaseProvider>(context, listen: false)
        .getUserData()
        .then((value) {
      setState(() {
        _userDataLoaded = true;
      });
      Provider.of<DatabaseProvider>(context, listen: false)
          .getUserBalance()
          .then((value) {
        Provider.of<DatabaseProvider>(context, listen: false)
            .getNotificationsUnreadCount();
        Provider.of<DatabaseProvider>(context, listen: false)
            .getMessagesUnreadCount();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    ExchangeRateProvider exr =
        Provider.of<ExchangeRateProvider>(context, listen: true);
    DatabaseProvider db = Provider.of<DatabaseProvider>(context, listen: true);
    return _userDataLoaded
        ? DefaultTabController(
            length: 3,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: _screen[_selectedPageIndex],
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                mini: true,
                child: const Icon(CupertinoIcons.arrow_2_circlepath,
                    color: Colors.white),
                onPressed: () {
                  if (exr.currencies.isNotEmpty) {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (ctx) {
                          return sheet(size, theme, exr);
                        });
                  }
                },
              ),
              bottomNavigationBar: BottomNavigationBar(
                elevation: 20,
                backgroundColor: theme.getBackground(),
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedPageIndex,
                onTap: _handleNavigationTap,
                items: [
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.bar_chart), label: ''),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.compare_arrows), label: ''),
                  BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          const Icon(Icons.person),
                          if (db.unreadNotificationCount != 0 ||
                              db.unreadMessagesCount != 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Text(
                                (db.unreadMessagesCount +
                                        db.unreadNotificationCount)
                                    .toString(),
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: size.width * .03),
                              ),
                            ),
                        ],
                      ),
                      label: ''),
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.settings), label: ''),
                ],
              ),
            ),
          )
        : const LoadingScreen();
  }

  Widget sheet(Size size, ThemeProvider theme, ExchangeRateProvider exr) {
    return StatefulBuilder(builder: (BuildContext ctx2, StateSetter setState) {
      return Container(
          alignment: Alignment.topCenter,
          height: size.height * .8,
          width: size.width,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0))),
          padding: EdgeInsets.only(
            left: size.width * .2,
            right: size.width * .2,
            top: size.height * .05,
            bottom: size.height * .05,
            //bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: exr.currencies.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: size.height * .06,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: theme.themeAccent)),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * .1,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            style: TextStyle(fontSize: size.width * 0.04),
                            iconEnabledColor: theme.swapBackground(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            alignment: Alignment.center,
                            isExpanded: true,
                            value: _convertFrom,
                            items: exr.currencies.map((String value) {
                              return DropdownMenuItem<String>(
                                alignment: Alignment.center,
                                value: value,
                                child: Text(
                                  value,
                                  style:
                                      TextStyle(color: theme.swapBackground()),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _convertFrom = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      VerticalSpace(size: size, percentage: 0.01),
                      Icon(
                        CupertinoIcons.arrow_down,
                        color: theme.themeAccent,
                      ),
                      VerticalSpace(size: size, percentage: 0.01),
                      Container(
                        height: size.height * .06,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: theme.themeAccent)),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * .1,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            style: TextStyle(fontSize: size.width * 0.04),
                            iconEnabledColor: theme.swapBackground(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            alignment: Alignment.center,
                            isExpanded: true,
                            value: _convertTo,
                            items: exr.currencies.map((String value) {
                              return DropdownMenuItem<String>(
                                alignment: Alignment.center,
                                value: value,
                                child: Text(
                                  value,
                                  style:
                                      TextStyle(color: theme.swapBackground()),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _convertTo = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      VerticalSpace(size: size, percentage: 0.02),
                      TextField(
                        controller: _amountController,
                        minLines: 1,
                        maxLines: 1,
                        autofocus: true,
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
                            labelText: strings["amount"]!),
                        keyboardType: TextInputType.number,
                      ),
                      VerticalSpace(size: size, percentage: 0.02),
                      Text(_convertResult.toString()),
                      VerticalSpace(size: size, percentage: 0.03),
                      _isConverting
                          ? const CircularProgressIndicator.adaptive()
                          : SizedBox(
                              width: size.width,
                              child: ElevatedButton(
                                  onPressed: () => _convert(setState),
                                  child: Text(
                                    strings['convert']!,
                                    style: const TextStyle(color: Colors.white),
                                  )),
                            )
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator.adaptive(),
                ));
    });
  }
}
