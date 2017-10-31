import 'dart:async';
import 'package:flutter/services.dart';

/*
  Author: Art

  Crash Reporting dart file for the application.
  Sends Exception message to Firebase Crash Reporting
 */
class MainFrameCrashReport {

  static const MethodChannel _channel = const MethodChannel('firebase_crash');

  static Future send(String errorMessage) async {
    return _channel.invokeMethod("reportMainFrameCrash", <String, dynamic> {
      "exceptionMessage": errorMessage
    });
  }
}