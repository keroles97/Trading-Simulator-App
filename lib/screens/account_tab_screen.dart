import 'package:app/constants/strings.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/chat_support_screen.dart';
import 'package:app/screens/edit_data_screen.dart';
import 'package:app/screens/notifications_screen.dart';
import 'package:app/screens/wallet_screen.dart';
import 'package:app/widgets/gray_divider.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountTabScreen extends StatefulWidget {
  const AccountTabScreen({Key? key}) : super(key: key);

  @override
  _AccountTabScreenState createState() => _AccountTabScreenState();
}

class _AccountTabScreenState extends State<AccountTabScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedPageIndex = 0;

  final List<Widget> _screen = [
    const NotificationsScreen(),
    const WalletScreen(),
    const ChatSupportScreen(),
    const EditDataScreen(),
  ];

  Future<void> _handleNavigationTap(int index) async {
    if (index == 4) {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      return;
    }
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    DatabaseProvider db = Provider.of<DatabaseProvider>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * .05),
        child: Container(
            height: size.height * .05,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: size.width * .02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  onTap: () {
                    _scaffoldKey.currentState!.openDrawer();
                  },
                  child: Icon(
                    Icons.menu,
                    color: theme.themeAccent,
                    size: size.height * .03,
                  ),
                ),
              ],
            )),
      ),
      body: _screen[_selectedPageIndex],
      drawer: SizedBox(
        width: size.width * .7,
        child: Drawer(
          elevation: 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: size.width * .7,
                  color: theme.themeAccent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      VerticalSpace(size: size, percentage: 0.02),
                      Text(
                        db.name!.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      VerticalSpace(size: size, percentage: 0.005),
                      Text(
                        db.email!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      VerticalSpace(size: size, percentage: 0.03),
                    ],
                  ),
                ),
                GrayDivider(size: size),
                drawerItem(
                    db, theme, size, "notifications", 0, Icons.notifications),
                GrayDivider(size: size),
                drawerItem(db, theme, size, "my_wallet", 1,
                    Icons.account_balance_wallet),
                GrayDivider(size: size),
                drawerItem(db, theme, size, "chat_support", 2,
                    Icons.account_balance_wallet),
                GrayDivider(size: size),
                drawerItem(db, theme, size, "change_password", 3, Icons.lock),
                GrayDivider(size: size),
                drawerItem(db, theme, size, "sign_out", 4, Icons.exit_to_app),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drawerItem(DatabaseProvider db, ThemeProvider theme, Size size,
      String textKey, int index, IconData icon) {
    return ListTile(
      horizontalTitleGap: 0,
      contentPadding:
          EdgeInsets.fromLTRB(size.width * .01, 0, size.width * .03, 0),
      selected: index == 4 ? false : _selectedPageIndex == index,
      selectedTileColor: theme.themeMode == "dark"
          ? const Color.fromRGBO(255, 255, 255, 0.1)
          : const Color.fromRGBO(219, 219, 219, 0.6),
      leading: Icon(
        icon,
        color: theme.swapBackground(),
      ),
      trailing: index == 2 && db.unreadMessagesCount > 0
          ? Text(
              db.unreadMessagesCount.toString(),
              style: const TextStyle(color: Colors.green),
            )
          : null,
      title: Text(strings[textKey]!),
      onTap: () => _handleNavigationTap(index),
    );
  }
}
