import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:myapp/MFGlobals.dart' as global;

/*
  Author: Art

  Firebase Analytics dart file for the application.
  Sends Analytics items to Firebase Analytics

 */

class AnalyticsUtil {

  static FirebaseAnalytics analytics = global.analytics;
  static FirebaseAnalyticsObserver observer = global.observer;

  static initializeAnalytics() {
    global.analytics = new FirebaseAnalytics();
    global.observer = new FirebaseAnalyticsObserver(analytics: global.analytics);
  }

  static Future setCurrentScreen(String screenName, {String screenClassName}) async {
    if(screenClassName == null) {
      await analytics.setCurrentScreen(screenName: screenName);
    } else {
      await analytics.setCurrentScreen(
          screenName: screenName,
          screenClassOverride: screenClassName
      );
    }
  }

  static Future sendAnalyticsEvent(String eventName, {Map<String, dynamic> params}) async {
    if(params == null) {
      await analytics.logEvent(name: eventName);
    } else {
      await analytics.logEvent(name: eventName, parameters: params);
    }
  }
}