import 'package:flutter/material.dart';
import 'package:myapp/MainFrameRoute.dart';
import 'src/util/CrashlyticsReport.dart';
import 'src/util/AnalyticsUtil.dart';
import 'MFGlobals.dart' as global;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

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
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    AnalyticsUtil.initializeAnalytics();

    /*FlutterError.onError = (errorDetails) {
      print("MAIN caught errors: ${errorDetails.stack.toString()}");
      print("LOGGING ONCRASHLYTICS");
      //MainFrameCrashReport.send(errorDetails.exception.toString());
      if(global.devicePlatform == "android") {
        CrashlyticsReport.logException(errorDetails.exceptionAsString());
      }
    };*/

    ThemeData theme = new ThemeData(
      primaryColor: new Color(0xFF324261),
      fontFamily: "Montserrat-Regular",
      canvasColor: new Color(0xFF324261),
      brightness: Brightness.dark,
      hintColor: Colors.white,
      accentColor: Colors.white,
      dialogBackgroundColor: new Color(0xFF324261),
      textSelectionHandleColor: new Color(0xFF53617C),
    );

    return new MaterialApp(
      onGenerateRoute: getMainFrameOnRoute,
      routes: getMainFrameRoute(),
      navigatorObservers: <NavigatorObserver>[AnalyticsUtil.observer],
      theme: theme,
    );
  }
}