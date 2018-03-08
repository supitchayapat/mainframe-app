package com.yourcompany.firebasedynamiclink;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.app.Activity;
import android.net.Uri;
import android.content.Intent;
import android.util.Log;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.dynamiclinks.DynamicLink;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;

/**
 * FirebaseDynamicLinkPlugin
 */
public class FirebaseDynamicLinkPlugin implements MethodCallHandler {
  private int nextHandle = 0;
  private final MethodChannel channel;
  private final Activity activity;
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "firebase_dynamic_link");
    channel.setMethodCallHandler(new FirebaseDynamicLinkPlugin(registrar.activity(), channel));
  }

  private FirebaseDynamicLinkPlugin(Activity activity, MethodChannel channel) {
    this.activity = activity;
    this.channel = channel;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getDynamicLink")) {
      final int handle = nextHandle++;
      FirebaseDynamicLinks.getInstance()
              .getDynamicLink(activity.getIntent())
              .addOnSuccessListener(activity, new GetLinkSuccessListener(result));

    } else {
      result.notImplemented();
    }
  }

  private class GetLinkSuccessListener implements OnSuccessListener<PendingDynamicLinkData> {
    private final Result result;

    GetLinkSuccessListener(Result result) {
      this.result = result;
    }

    @Override
    public void onSuccess(PendingDynamicLinkData pendingDynamicLinkData) {
      // Get deep link from result (may be null if no link is found)
      Uri deepLink = null;
      if (pendingDynamicLinkData != null) {
        deepLink = pendingDynamicLinkData.getLink();
      }
      if(deepLink != null) {
        Log.i("deeplink", deepLink.toString());
        result.success(deepLink.getEncodedPath());
      } else {
        Log.i("deeplink", "Deep link null");
        result.success(null);
      }
    }
  }
}
