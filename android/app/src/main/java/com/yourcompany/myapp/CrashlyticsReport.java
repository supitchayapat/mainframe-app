package com.yourcompany.myapp;

import java.util.List;
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
        if (call.method.equals("logException")) {
            String msg = call.argument("exceptionMessage");
            Exception ex = call.argument("exception");
            List<String> logs = call.argument("exceptionLogs");

            if(logs != null && !logs.isEmpty()) {
                for(String log : logs) {
                    Crashlytics.log(log);
                }
            }

            if(ex != null) { // not yet implemented can only get exception message
                Crashlytics.logException(ex);
            }
            else if(msg != null) {
                Crashlytics.logException(new Exception(msg));
            }
        }
        else if(call.method.equals("logMessage")) {
            String msg = call.argument("logMessage");
            Crashlytics.log(msg);
        }
        else {
            result.notImplemented();
        }
    }
}
