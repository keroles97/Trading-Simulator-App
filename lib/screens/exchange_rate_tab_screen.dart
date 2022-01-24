import 'dart:async';

import 'package:app/constants/strings.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/exchange_rate_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/currency_historical_rate_screen.dart';
import 'package:app/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExchangeRateTabScreen extends StatefulWidget {
  const ExchangeRateTabScreen({Key? key}) : super(key: key);

  @override
  _ExchangeRateTabScreenState createState() => _ExchangeRateTabScreenState();
}

class _ExchangeRateTabScreenState extends State<ExchangeRateTabScreen> {
  final List<String> _sortList = [
    'Alphabetically',
    'Price Ascending',
    'Price Descending',
  ];
  String _sortType = 'Price Ascending';
  bool _ratesLoaded = false;
  Timer? _exchangeRatesUpdateTimer;

  String _dropDownValue() {
    switch (_sortType) {
      case 'Alphabetically':
        return 'A:Z';
      case 'Price Ascending':
        return '1>>2';
      case 'Price Descending':
        return '2>>1';
      default:
        return 'A:Z';
    }
  }

  void _runExchangeRatesTimer() {
    _exchangeRatesUpdateTimer =
        Timer.periodic(const Duration(minutes: 1), (Timer t) async {
      Provider.of<ExchangeRateProvider>(context, listen: false)
          .getExchangeRates(
              await Provider.of<DatabaseProvider>(context, listen: false)
                  .getSpecialCurrencies(),
              _sortType);
    });
  }

  void _currencyOverview(String currency) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return CurrencyHistoricalRateScreen(currency: currency);
    }));
  }

  Future<void> getCurrencies() async {
    Provider.of<ExchangeRateProvider>(context, listen: false)
        .getExchangeRates(
            await Provider.of<DatabaseProvider>(context, listen: false)
                .getSpecialCurrencies(),
            _sortType)
        .then((value) {
      setState(() {
        _ratesLoaded = true;
      });
      _runExchangeRatesTimer();
    });
  }

  @override
  void initState() {
    getCurrencies();
    super.initState();
  }

  @override
  void dispose() {
    if (_exchangeRatesUpdateTimer != null) {
      _exchangeRatesUpdateTimer!.cancel();
      _exchangeRatesUpdateTimer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    ExchangeRateProvider exr =
        Provider.of<ExchangeRateProvider>(context, listen: true);
    return _ratesLoaded
        ? SizedBox(
            height: size.height * .9,
            child: exr.rates.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * .02),
                          height: size.height * .05,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: theme.themeAccent))),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '1 coin',
                                style: TextStyle(
                                    color: theme.themeAccent,
                                    fontSize: size.width * .04),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isDense: true,
                                  iconEnabledColor: theme.swapBackground(),
                                  alignment: Alignment.centerRight,
                                  value: _sortType,
                                  items: _sortList.map((String value) {
                                    return DropdownMenuItem<String>(
                                      alignment: Alignment.centerLeft,
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: size.width * .04,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    if (_sortType != value) {
                                      setState(() {
                                        _sortType = value!;
                                      });
                                      exr.sort(_sortType);
                                    }
                                  },
                                ),
                              ),
                              Text(
                                'currency per 1\$',
                                style: TextStyle(
                                    color: theme.themeAccent,
                                    fontSize: size.width * .04),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height * .85,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: exr.rates.length,
                              itemBuilder: (ctx, i) {
                                return InkWell(
                                  onTap: () =>
                                      _currencyOverview(exr.rates[i].code!),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: theme.themeAccent,
                                                width: size.height * .0005))),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.width * .04),
                                      margin: EdgeInsets.all(size.width * .03),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            exr.rates[i].code!,
                                            style: TextStyle(
                                                fontSize: size.width * .04),
                                          ),
                                          Text(
                                            exr.rates[i].value!,
                                            //exr.rates[i].value! + ' / 1\$',
                                            style: TextStyle(
                                                fontSize: size.width * .04),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  )
                : Center(child: Text(strings["unknown_error"]!)))
        : const LoadingScreen();
  }
}
