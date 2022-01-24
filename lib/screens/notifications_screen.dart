import 'package:app/constants/strings.dart';
import 'package:app/models/notification_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/loading_screen.dart';
import 'package:app/utils/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isNotificationsLoaded = false;
  List<NotificationModel> _notifications = [];

  @override
  initState() {
    Provider.of<DatabaseProvider>(context, listen: false)
        .getNotifications()
        .then((value) {
      setState(() {
        _notifications = value;
        _isNotificationsLoaded = true;
      });
      Provider.of<DatabaseProvider>(context, listen: false)
          .setNotificationsUnreadCount();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    DatabaseProvider db = Provider.of<DatabaseProvider>(context, listen: true);
    return Container(
      height: size.height,
      width: size.width,
      margin: EdgeInsets.symmetric(vertical: size.height * .02),
      child: _isNotificationsLoaded
          ? _notifications.isNotEmpty
              ? Container(
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: theme.themeAccent,
                              width: size.height * .0005))),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _notifications.length,
                      itemBuilder: (ctx, i) {
                        return Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * .01,
                              horizontal: size.width * .03),
                          decoration: BoxDecoration(
                              color: i + 1 <= db.unreadNotificationCount
                                  ? Colors.orangeAccent.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border(
                                  bottom: BorderSide(
                                      color: theme.themeAccent,
                                      width: size.height * .0005))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _notifications[i].alert!,
                                style: TextStyle(fontSize: size.width * .04),
                              ),
                              Container(
                                width: size.width,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatDateTime(_notifications[i].date!),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: size.width * .03),
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                )
              : Center(
                  child: Text(
                    strings['no_notifications']!,
                    style: TextStyle(fontSize: size.width * .04),
                  ),
                )
          : const LoadingScreen(),
    );
  }
}
