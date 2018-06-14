import 'dart:async';
import 'package:flutter/services.dart';

/*
  Author: Art

  Crash Reporting dart file for the application.
  Sends Exception message to Firebase Crash Reporting
 */
class CrashlyticsReport {

  static const MethodChannel _channel = const MethodChannel('crashlytics');

  static Future send(String errorMessage) async {
    print("BEFORE INVOKE crash");
    return _channel.invokeMethod("reportMainFrameCrash", <String, dynamic> {
      "exceptionMessage": errorMessage
    });
  }
}