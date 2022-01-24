import 'package:app/constants/strings.dart';
import 'package:app/models/in_process_request_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/utils/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loading_screen.dart';

class CompletedRequestsScreen extends StatefulWidget {
  const CompletedRequestsScreen({Key? key}) : super(key: key);

  @override
  _CompletedRequestsScreenState createState() => _CompletedRequestsScreenState();
}

class _CompletedRequestsScreenState extends State<CompletedRequestsScreen> {
  late List<InProcessRequestModel> _filteredRequests;
  late List<InProcessRequestModel> _allRequests;
  String _type = 'buying';
  bool _filteredRequestsLoaded = false;

  void _filterRequests(String type) {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    setState(() {
      if (type == 'buying') {
        _type = 'buying';
        _filteredRequests = _allRequests
            .where((element) => element.buyerUId == db.uId)
            .toList();
      } else {
        _type = 'selling';
        _filteredRequests = _allRequests
            .where((element) => element.sellerUId == db.uId)
            .toList();
      }
    });
  }

  void _getRequests() {
    Provider.of<DatabaseProvider>(context, listen: false)
        .getCompletedRequests()
        .then((value) {
      setState(() {
        _allRequests = value;
        _filterRequests('buying');
        _filteredRequestsLoaded = true;
      });
    });
  }

  @override
  void initState() {
    _getRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.centerRight,
          width: size.width,
          height: size.height * .05,
          margin: EdgeInsets.symmetric(horizontal: size.width * .02),
          child: InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text(
                        strings['filter_requests']!,
                        style: TextStyle(
                            color: theme.swapBackground(),
                            fontSize: size.height * 0.025,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          child: Text(
                            strings['buying_requests']!,
                          ),
                          onPressed: () {
                            _filterRequests('buying');
                            Navigator.of(context).pop(context);
                          },
                        ),
                        TextButton(
                          child: Text(
                            strings['selling_requests']!,
                          ),
                          onPressed: () {
                            _filterRequests('selling');
                            Navigator.of(context).pop(context);
                          },
                        )
                      ],
                    );
                  });
            },
            child: Icon(
              Icons.sort,
              color: theme.swapBackground(),
              size: size.height * .03,
            ),
          ),
        ),
        Container(
          width: size.width,
          height: size.height * .05,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: theme.themeAccent, width: size.height * .0005))),
          margin: EdgeInsets.all(size.width * .02),
          child: Text(
            strings[_type == 'buying'
                ? 'your_buying_requests'
                : 'your_selling_requests']!,
            style: TextStyle(
              color: theme.themeAccent,
              fontSize: size.width * .04,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              bottom: size.height * .03, top: size.height * .01),
          alignment: Alignment.topCenter,
          width: size.width,
          height: size.height * .67,
          child: _filteredRequestsLoaded
              ? _filteredRequests.isNotEmpty
              ? ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredRequests.length,
              itemBuilder: (ctx, i) {
                return Container(
                  width: size.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: theme.themeAccent,
                              width: size.height * .0005))),
                  child: Container(
                    width: size.width,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(
                        vertical: size.width * .02),
                    margin: EdgeInsets.symmetric(
                        horizontal: size.width * .03),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              strings['currency']! + ': ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width * .04),
                            ),
                            Text(
                              _filteredRequests[i].currency!,
                              style:
                              TextStyle(fontSize: size.width * .04),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              strings['amount']! + ': ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width * .04),
                            ),
                            Text(
                              _filteredRequests[i].amount!,
                              style:
                              TextStyle(fontSize: size.width * .04),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              strings['price_per_coin']! + ': ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width * .04),
                            ),
                            Text(
                              _filteredRequests[i].pricePerCoin!,
                              style:
                              TextStyle(fontSize: size.width * .04),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              strings['total_price']! + ': ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width * .04),
                            ),
                            Text(
                              _filteredRequests[i].totalPrice!,
                              style:
                              TextStyle(fontSize: size.width * .04),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              strings['fees']! + ': ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width * .04),
                            ),
                            Text(
                              _filteredRequests[i].fees!,
                              style:
                              TextStyle(fontSize: size.width * .04),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              strings['total_cost']! + ': ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width * .04),
                            ),
                            Text(
                              _filteredRequests[i].totalCost!,
                              style:
                              TextStyle(fontSize: size.width * .04),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              strings['accepted_date']! + ': ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width * .04),
                            ),
                            Text(
                              formatDateTime(_filteredRequests[i]
                                  .date!
                                  .toString()),
                              style:
                              TextStyle(fontSize: size.width * .04),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              })
              : Center(
            child: Text(strings['no_requests']!),
          )
              : const LoadingScreen(),
        ),
      ],
    );
  }
}
