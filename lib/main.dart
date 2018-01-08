import 'package:flutter/material.dart';
import 'package:myapp/MainFrameRoute.dart';
import 'package:myapp/src/util/FirebaseCrashReport.dart';

/*
  Author: Art

  This is the main dart file for the application.
  It contains the login and sign-up screen widgets
 */
void main() {
  FlutterError.onError = (errorDetails) {
    print("main caught errors: ${errorDetails}");
    MainFrameCrashReport.send(errorDetails.exception);
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

  runApp(new MaterialApp(
      onGenerateRoute: getMainFrameOnRoute,
      routes: getMainFrameRoute(),
      theme: theme,
  ));
}