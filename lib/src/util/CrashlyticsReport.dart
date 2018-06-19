import 'dart:async';
import 'package:flutter/services.dart';
import 'package:myapp/MFGlobals.dart' as global;

/*
  Author: Art

  Crash Reporting dart file for the application.
  Sends Exception message to Firebase Crash Reporting
 */
class CrashlyticsReport {

  static const MethodChannel _channel = const MethodChannel('crashlytics');

  static Future logException(String errorMessage) async {
    print("INVOKE EXCEPTION LOGGING");
    return _channel.invokeMethod("logException", <String, dynamic> {
      "exceptionMessage": errorMessage,
      "exceptionLogs": global.messageLogs
    });
  }

  static Future logExceptionClass(Exception ex) async {
    print("INVOKE EXCEPTION LOGGING");
    return _channel.invokeMethod("logException", <String, dynamic> {
      "exception": ex,
      "exceptionLogs": global.messageLogs
    });
  }

  static Future logMessage(String logMessage) async {
    return _channel.invokeMethod("logException", <String, dynamic> {
      "logMessage": logMessage
    });
  }
}