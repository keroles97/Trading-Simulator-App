import 'package:app/constants/strings.dart';
import 'package:app/models/in_process_request_model.dart';
import 'package:app/models/selling_buying_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/utils/date_time_format.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:app/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestOverviewScreen extends StatefulWidget {
  const RequestOverviewScreen(
      {Key? key, required this.request, required this.isBuyingRequest})
      : super(key: key);

  final SellingBuyingModel request;
  final bool isBuyingRequest;

  @override
  _RequestOverviewScreenState createState() => _RequestOverviewScreenState();
}

class _RequestOverviewScreenState extends State<RequestOverviewScreen> {
  double _totalCost = 0.0;
  double _fees = 0.0;
  bool _isLoading = false;

  void _showConfirmationDialog(
      DatabaseProvider db, ThemeProvider theme, Size size) {
    final double balance =
        double.parse(db.balance.firstWhere((e) => e.code == 'USD').value!);
    if (_totalCost > balance) {
      showSnackBar(context, 'insufficient_balance');
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              strings['accept_request_confirmation']!,
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
                  strings['accept']!,
                ),
                onPressed: () {
                  _acceptRequest(db);
                  Navigator.of(context).pop(context);
                },
              ),
              TextButton(
                child: Text(
                  strings['cancel']!,
                ),
                onPressed: () {
                  Navigator.of(context).pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void> _acceptRequest(DatabaseProvider db) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final String path = widget.isBuyingRequest
          ? 'buyingRequests/${widget.request.id}'
          : 'sellingRequests/${widget.request.id}';
      await db.deleteBuyingSellingRequest(path);

      InProcessRequestModel data = InProcessRequestModel(
        id: widget.request.id,
        sellerUId: widget.isBuyingRequest ? db.uId : widget.request.sellerUId,
        buyerUId: widget.isBuyingRequest ? widget.request.buyerUId : db.uId,
        currency: widget.request.currency,
        amount: widget.request.amount,
        pricePerCoin: widget.request.pricePerCoin,
        totalPrice: widget.request.totalPrice,
        fees: _fees.toString(),
        totalCost: _totalCost.toString(),
        date: {".sv": "timestamp"},
      );

      await db.addInProcessingRequest(
          'inProcessRequests/${widget.request.id}', data.toMap());

      showSnackBar(context, 'moved_to_in_processing');
      Navigator.of(context).pop(true);
    } catch (error) {
      print(error.toString());
      showInfoAlertDialog(context, strings['unknown_error']!, true);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showDeleteConfirmationDialog(
      DatabaseProvider db, ThemeProvider theme, Size size) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              strings['delete_request_confirmation']!,
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
                  strings['delete']!,
                ),
                onPressed: () {
                  _deleteRequest(db);
                  Navigator.of(context).pop(context);
                },
              ),
              TextButton(
                child: Text(
                  strings['cancel']!,
                ),
                onPressed: () {
                  Navigator.of(context).pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void> _deleteRequest(DatabaseProvider db) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final String path = widget.isBuyingRequest
          ? 'buyingRequests/${widget.request.id}'
          : 'sellingRequests/${widget.request.id}';
      await db.deleteBuyingSellingRequest(path);

      showSnackBar(context, 'request_deleted');
      Navigator.of(context).pop(true);
    } catch (error) {
      print(error.toString());
      showInfoAlertDialog(context, strings['unknown_error']!, true);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fees = ((double.parse(widget.request.totalPrice!) * 2) / 100);
    _totalCost = (_fees + double.parse(widget.request.totalPrice!));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    DatabaseProvider db = Provider.of<DatabaseProvider>(context, listen: false);
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
            body: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(
              horizontal: size.width * .02, vertical: size.height * .01),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                strings[widget.isBuyingRequest ? 'buying_request' : 'selling_request']!,
                style: TextStyle(
                    color: theme.themeAccent,
                    fontSize: size.width * .04),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings['currency']! + ': ',
                    style: TextStyle(
                        color: Colors.grey, fontSize: size.width * .04),
                  ),
                  Text(
                    widget.request.currency!,
                    style: TextStyle(fontSize: size.width * .04),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings['publish_date']! + ': ',
                    style: TextStyle(
                        color: Colors.grey, fontSize: size.width * .04),
                  ),
                  Text(
                    formatDateTime(widget.request.date!.toString()),
                    style: TextStyle(fontSize: size.width * .04),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings['amount']! + ': ',
                    style: TextStyle(
                        color: Colors.grey, fontSize: size.width * .04),
                  ),
                  Text(
                    widget.request.amount!,
                    style: TextStyle(fontSize: size.width * .04),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings['price_per_coin']! + ': ',
                    style: TextStyle(
                        color: Colors.grey, fontSize: size.width * .04),
                  ),
                  Text(
                    widget.request.pricePerCoin!,
                    style: TextStyle(fontSize: size.width * .04),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings['total_price']! + ': ',
                    style: TextStyle(
                        color: Colors.grey, fontSize: size.width * .04),
                  ),
                  Text(
                    widget.request.totalPrice!,
                    style: TextStyle(fontSize: size.width * .04),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings['fees']! + ': ',
                    style: TextStyle(
                        color: Colors.grey, fontSize: size.width * .04),
                  ),
                  Text(
                    _fees.toString(),
                    style: TextStyle(fontSize: size.width * .04),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings['total_cost']! + ': ',
                    style: TextStyle(
                        color: Colors.grey, fontSize: size.width * .04),
                  ),
                  Text(
                    _totalCost.toString(),
                    style: TextStyle(fontSize: size.width * .04),
                  )
                ],
              ),
              if (widget.request.buyerUId! != db.uId &&
                  widget.request.sellerUId! != db.uId)
                _isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : Container(
                        width: size.width,
                        margin: EdgeInsets.symmetric(
                            horizontal: size.width * .05, vertical: 0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(
                                      vertical: size.height * .01)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                            ),
                            onPressed: () =>
                                _showConfirmationDialog(db, theme, size),
                            child: Text(
                              strings["accept"]!,
                              style: TextStyle(
                                  fontSize: size.height * .025,
                                  color: Colors.white),
                            )),
                      ),
              if (widget.request.buyerUId! == db.uId ||
                  widget.request.sellerUId! == db.uId)
                _isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : Container(
                        width: size.width,
                        margin: EdgeInsets.symmetric(
                            horizontal: size.width * .05, vertical: 0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(
                                      vertical: size.height * .01)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                            ),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(db, theme, size),
                            child: Text(
                              strings["delete"]!,
                              style: TextStyle(
                                  fontSize: size.height * .025,
                                  color: Colors.white),
                            )),
                      ),
            ],
          ),
        )),
      ),
    );
  }
}
