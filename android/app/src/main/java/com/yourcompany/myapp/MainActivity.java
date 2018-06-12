package com.yourcompany.myapp;

import android.os.Bundle;

import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.FlutterException;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.crashlytics.android.Crashlytics;
import io.fabric.sdk.android.Fabric;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Fabric.with(this, new Crashlytics());
    GeneratedPluginRegistrant.registerWith(this);
    // add a method channel to call firebase crash reporting
    new MethodChannel(getFlutterView(), "firebase_crash").setMethodCallHandler(new FirebaseCrashPlugin());
  }
}
