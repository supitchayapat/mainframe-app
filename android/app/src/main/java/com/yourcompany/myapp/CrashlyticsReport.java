package com.yourcompany.myapp;

import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import com.crashlytics.android.Crashlytics;
import io.fabric.sdk.android.Fabric;

/*
    Author: Art
    Crashlytics Plugin in Firebase. Track errors from the wild.
    Cannot implement a good stack trace since PlatformException is not available.
    Only Exception messages
 */
public class CrashlyticsReport implements MethodCallHandler {

    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        if (call.method.equals("reportMainFrameCrash")) {
            String msg = call.argument("exceptionMessage");
            Exception ex = call.argument("exception");

            Crashlytics.log("Test logging");
            Crashlytics.logException(new Exception("Has something to do with issues"));

            /*if(ex != null) { // not yet implemented can only get exception message
                FirebaseCrash.report(ex);
            }
            else if(msg != null) {
                FirebaseCrash.report(new Exception(msg));
            }*/
        }
        else {
            result.notImplemented();
        }
    }
}
