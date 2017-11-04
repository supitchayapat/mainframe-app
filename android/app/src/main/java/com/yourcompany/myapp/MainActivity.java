package com.yourcompany.myapp;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    // add a method channel to call firebase crash reporting
    new MethodChannel(getFlutterView(), "firebase_crash").setMethodCallHandler(new FirebaseCrashPlugin());
  }

  @java.lang.Override
  public void onBackPressed() {

    /*if(super.getFlutterView() != null) {
      System.out.println("Popped route");
      super.getFlutterView().popRoute();
    } else {
      System.out.println("back pressed");
      super.onBackPressed();
    }*/
    super.onBackPressed();
  }
}
