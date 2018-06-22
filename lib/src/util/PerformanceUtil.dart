import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_performance/firebase_performance.dart';

/*
  Author: Art

  Crash Reporting dart file for the application.
  Sends Exception message to Firebase Crash Reporting
 */
class PerformanceUtil {

  static FirebasePerformance _performance = FirebasePerformance.instance;
  static Trace trace;

  static Future startTrace(String traceName) async {
    trace = _performance.newTrace(traceName);
    trace.incrementCounter("counter1", 16);
    print("START PERFORMANCE TRACE");
    bool isEnabled = await _performance.isPerformanceCollectionEnabled();
    print("PERFORMANCE ENABLED: $isEnabled");
    await trace.start();
  }

  static Future stopTrace() async {
    if(trace != null) {
      print("STOP PERFORMANCE TRACE");
      print(trace.attributes);
      await trace.stop();
    }
  }
}