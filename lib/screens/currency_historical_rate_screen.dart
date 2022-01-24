import 'package:app/constants/strings.dart';
import 'package:app/models/currency_historical_rate_model.dart';
import 'package:app/providers/exchange_rate_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/add_selling_request_screen.dart';
import 'package:app/screens/loading_screen.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'add_buying_request_screen.dart';

class CurrencyHistoricalRateScreen extends StatefulWidget {
  const CurrencyHistoricalRateScreen({Key? key, required this.currency})
      : super(key: key);

  final String currency;

  @override
  _CurrencyHistoricalRateScreenState createState() =>
      _CurrencyHistoricalRateScreenState();
}

class _CurrencyHistoricalRateScreenState
    extends State<CurrencyHistoricalRateScreen> {
  bool _isChartsLoaded = false;
  List<CurrencyHistoricalRateModel> _currencyData = [];
  List<CurrencyHistoricalRateModel> _currencyDataReversed = [];

  @override
  void initState() {
    Provider.of<ExchangeRateProvider>(context, listen: false)
        .dailyHistoricalRate(widget.currency)!
        .then((value) {
      setState(() {
        _currencyData = value;
        _currencyDataReversed = value.reversed.toList();
        _isChartsLoaded = true;
      });
    });
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
            body: _isChartsLoaded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_currencyData.isNotEmpty)
                        Container(
                            alignment: Alignment.center,
                            height: size.height * .37,
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * .02),
                            child: SfCartesianChart(
                                margin: EdgeInsets.only(
                                    right: size.width * .05,
                                    top: size.height * .01),
                                borderWidth: 0,
                                plotAreaBorderWidth: 0,
                                title: ChartTitle(
                                    text: widget.currency,
                                    textStyle:
                                        TextStyle(color: theme.themeAccent)),
                                primaryXAxis: DateTimeAxis(
                                  labelStyle:
                                      TextStyle(fontSize: size.width * .02),
                                  dateFormat: intl.DateFormat('yyyy-MM-dd'),
                                  visibleMaximum: _currencyData.last.date,
                                  visibleMinimum: _currencyData.first.date,
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  axisLine: const AxisLine(width: 0),
                                  interval: 0.5,
                                  intervalType: DateTimeIntervalType.years,
                                ),
                                primaryYAxis: NumericAxis(
                                  labelStyle:
                                      TextStyle(fontSize: size.width * .02),
                                ),
                                tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  header: '',
                                ),
                                series: <ChartSeries>[
                                  LineSeries<CurrencyHistoricalRateModel,
                                          DateTime>(
                                      width: size.width * .0017,
                                      color: theme.themeAccent,
                                      dataSource: _currencyData,
                                      xValueMapper:
                                          (CurrencyHistoricalRateModel currency,
                                                  _) =>
                                              currency.date,
                                      yValueMapper:
                                          (CurrencyHistoricalRateModel currency,
                                                  _) =>
                                              currency.value)
                                ])),
                      VerticalSpace(size: size, percentage: 0.03),
                      if (_currencyDataReversed.isNotEmpty)
                        Container(
                          alignment: Alignment.center,
                          height: size.height * .37,
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * .02),
                          child: ListView.builder(
                              shrinkWrap: true,
                              reverse: false,
                              itemCount: _currencyDataReversed.length,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        _currencyDataReversed[i]
                                            .date
                                            .toString()
                                            .replaceAll('00:00:00.000', ''),
                                        style: TextStyle(
                                            fontSize: size.width * .04),
                                      ),
                                      Text(
                                        '${_currencyDataReversed[i].value} / 1\$',
                                        style: TextStyle(
                                            fontSize: size.width * .04),
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
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return const AddBuyingRequestScreen();
                              }));
                            },
                            child: Text(
                              strings['buy']!,
                              style: const TextStyle(color: Colors.white),
                            )),
                      ),
                      VerticalSpace(size: size, percentage: 0.005),
                      Container(
                        width: size.width,
                        margin:
                            EdgeInsets.symmetric(horizontal: size.width * .15),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return const AddSellingRequestScreen();
                              }));
                            },
                            child: Text(
                              strings['sell']!,
                              style: const TextStyle(color: Colors.white),
                            )),
                      )
                    ],
                  )
                : const LoadingScreen()),
      ),
    );
  }
}
