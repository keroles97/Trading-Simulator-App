import 'package:app/constants/strings.dart';
import 'package:app/models/selling_buying_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/add_buying_request_screen.dart';
import 'package:app/screens/request_overview_screen.dart';
import 'package:app/utils/date_time_format.dart';
import 'package:app/widgets/horizontal_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loading_screen.dart';

class BuyingRequestsScreen extends StatefulWidget {
  const BuyingRequestsScreen({Key? key}) : super(key: key);

  @override
  _BuyingRequestsScreenState createState() => _BuyingRequestsScreenState();
}

class _BuyingRequestsScreenState extends State<BuyingRequestsScreen> {
  late List<SellingBuyingModel> _requests;
  late List<SellingBuyingModel> _allRequests;
  bool _requestsLoaded = false;

  void _filterRequests() {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    setState(() {
      _requests =
          _allRequests.where((element) => element.buyerUId == db.uId).toList();
    });
  }

  Future<void> _requestOverview(SellingBuyingModel request) async {
    var result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return RequestOverviewScreen(
        request: request,
        isBuyingRequest: true,
      );
    }));
    if (result != null && result) {
      setState(() {
        _requestsLoaded = false;
        _allRequests.clear();
        _requests.clear();
      });
      _getRequests();
    }
  }

  Future<void> _addRequest() async {
    var result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return const AddBuyingRequestScreen();
    }));
    if (result != null && result) {
      setState(() {
        _requestsLoaded = false;
        _allRequests.clear();
        _requests.clear();
      });
      _getRequests();
    }
  }

  void _getRequests() {
    Provider.of<DatabaseProvider>(context, listen: false)
        .getBuyingRequests()
        .then((value) {
      setState(() {
        _requestsLoaded = true;
        _allRequests = value;
        _requests = value;
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
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings['buying_requests']!,
                style: TextStyle(
                    color: theme.themeAccent, fontSize: size.width * .04),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _addRequest(),
                    child: Icon(
                      Icons.add,
                      color: theme.swapBackground(),
                      size: size.height * .03,
                    ),
                  ),
                  HorizontalSpace(size: size, percentage: .03),
                  InkWell(
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
                                    strings['my_requests']!,
                                  ),
                                  onPressed: () {
                                    _filterRequests();
                                    Navigator.of(context).pop(context);
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    strings['all_requests']!,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _requests = _allRequests;
                                    });
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
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              bottom: size.height * .03, top: size.height * .01),
          alignment: Alignment.topCenter,
          width: size.width,
          height: size.height * .78,
          child: _requestsLoaded
              ? _requests.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _requests.length,
                      itemBuilder: (ctx, i) {
                        return InkWell(
                          onTap: () => _requestOverview(_requests[i]),
                          child: Container(
                            width: size.width,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: theme.themeAccent,
                                        width: size.height * .0005),
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
                                        _requests[i].currency!,
                                        style: TextStyle(
                                            fontSize: size.width * .04),
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
                                        _requests[i].amount!,
                                        style: TextStyle(
                                            fontSize: size.width * .04),
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
                                        _requests[i].pricePerCoin!,
                                        style: TextStyle(
                                            fontSize: size.width * .04),
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
                                        _requests[i].totalPrice!,
                                        style: TextStyle(
                                            fontSize: size.width * .04),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        strings['publish_date']! + ': ',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: size.width * .04),
                                      ),
                                      Text(
                                        formatDateTime(
                                            _requests[i].date!.toString()),
                                        style: TextStyle(
                                            fontSize: size.width * .04),
                                      )
                                    ],
                                  ),
                                ],
                              ),
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
