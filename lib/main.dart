import 'package:flutter/material.dart';
import 'package:myapp/MainFrameRoute.dart';

/*
  Author: Art

  This is the main dart file for the application.
  It contains the login and sign-up screen widgets
 */
void main() {
  runApp(new DanceFrameApp());
}

class DanceFrameApp extends StatefulWidget {
  @override
  _DanceFrameApp createState() => new _DanceFrameApp();
}

class _DanceFrameApp extends State<DanceFrameApp> {

  @override
  Widget build(BuildContext context) {

    FlutterError.onError = (errorDetails) {
      print("main caught errors: ${errorDetails}");
      //MainFrameCrashReport.send(errorDetails.exception.toString());
    };

    ThemeData theme = new ThemeData(
      primaryColor: new Color(0xFF324261),
      fontFamily: "Montserrat-Regular",
      canvasColor: new Color(0xFF324261),
      brightness: Brightness.dark,
      hintColor: Colors.white,
      accentColor: Colors.white,
      dialogBackgroundColor: new Color(0xFF324261),
    );

    return new MaterialApp(
      onGenerateRoute: getMainFrameOnRoute,
      routes: getMainFrameRoute(),
      theme: theme,
    );
  }
}