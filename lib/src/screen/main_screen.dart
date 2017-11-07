import 'package:flutter/material.dart';
import 'package:myapp/src/widget/EventsWidget.dart';

class MainScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => new _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  /*void _logout() {
    logoutUser();
    Navigator.popUntil(context, (_) => !Navigator.canPop(context));
    Navigator.of(context).pushNamed("/");
  }*/

  @override
  void initState() {
    super.initState();
    /*getCurrentUserProfile().then((usr) {
      //_mainFrameDrawer = new MainFrameDrawer(_scaffoldKey);
      MainFrameDrawer.currentUser=usr;
    });*/
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //ThemeData theme = Theme.of(context);
    ThemeData theme = new ThemeData(
        primaryColor: new Color(0xFF324261),
        fontFamily: "Montserrat-Regular",
        canvasColor: new Color(0xFF324261)
    );
    /*return new MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: new EventsWidget(),
    );*/
    return new EventsWidget();
  }
}