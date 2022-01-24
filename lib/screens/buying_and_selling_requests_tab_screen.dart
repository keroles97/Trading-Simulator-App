import 'package:app/constants/strings.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/buying_requests_screen.dart';
import 'package:app/screens/completed_requests_screen.dart';
import 'package:app/screens/in_process_Requests_screen.dart';
import 'package:app/screens/selling_requests_screen.dart';
import 'package:app/widgets/gray_divider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuyingAndSellingRequestsTabScreen extends StatefulWidget {
  const BuyingAndSellingRequestsTabScreen({Key? key}) : super(key: key);

  @override
  _BuyingAndSellingRequestsTabScreenState createState() =>
      _BuyingAndSellingRequestsTabScreenState();
}

class _BuyingAndSellingRequestsTabScreenState
    extends State<BuyingAndSellingRequestsTabScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedPageIndex = 0;

  final List<Widget> _screen = [
    const BuyingRequestsScreen(),
    const SellingRequestsScreen(),
    const InProcessRequestsScreen(),
    const CompletedRequestsScreen(),
  ];

  Future<void> _handleNavigationTap(int index) async {
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * .05),
        child: Container(
            height: size.height * .05,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: size.width * .02),
            child: InkWell(
              onTap: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              child: Icon(
                Icons.menu,
                color: theme.themeAccent,
                size: size.height * .03,
              ),
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
                GrayDivider(size: size),
                drawerItem(theme, size, "buying_requests", 0, Icons.arrow_back),
                GrayDivider(size: size),
                drawerItem(theme, size, "selling_requests", 1, Icons.arrow_forward),
                GrayDivider(size: size),
                drawerItem(theme, size, "in_process_requests", 2, Icons.cached),
                GrayDivider(size: size),
                drawerItem(theme, size, "completed_requests", 3, Icons.done),
                GrayDivider(size: size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drawerItem(ThemeProvider theme, Size size, String textKey, int index,
      IconData icon) {
    return ListTile(
      horizontalTitleGap: 0,
      contentPadding:
          EdgeInsets.fromLTRB(size.width * .01, 0, size.width * .03, 0),
      selected: _selectedPageIndex == index,
      selectedTileColor: theme.themeMode == "dark"
          ? const Color.fromRGBO(255, 255, 255, 0.1)
          : const Color.fromRGBO(219, 219, 219, 0.6),
      leading: Icon(
        icon,
        color: theme.swapBackground(),
      ),
      title: Text(strings[textKey]!),
      onTap: () => _handleNavigationTap(index),
    );
  }
}
