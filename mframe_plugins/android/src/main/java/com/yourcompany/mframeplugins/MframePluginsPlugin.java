package com.yourcompany.mframeplugins;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.content.Context;
import android.util.Log;
import android.database.Cursor;
import android.content.ContentResolver;
import android.provider.ContactsContract;
import android.support.v7.app.AppCompatActivity;
import android.support.v4.app.ActivityCompat;
import android.os.Build;
import android.Manifest;
import android.content.pm.PackageManager;
import android.widget.Toast;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableList;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * MframePluginsPlugin
 */
public class MframePluginsPlugin implements MethodCallHandler {
  private static final String TAG = "Mframe Plugin";
  // Request code for READ_CONTACTS. It can be any number > 0.
  private static final int PERMISSIONS_REQUEST_READ_CONTACTS = 100;

  private Activity activity;
  private Context mContext;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "mframe_plugins");
    channel.setMethodCallHandler(new MframePluginsPlugin(registrar.activity()));
  }

  MframePluginsPlugin(Activity activity) {
    this.activity = activity;
    this.mContext = activity.getApplicationContext();
  }

  private ImmutableMap<String, Object> showContacts() {
    // Check the SDK version and whether the permission is already granted or not.
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && this.mContext.checkSelfPermission(Manifest.permission.READ_CONTACTS) != mContext.getPackageManager().PERMISSION_GRANTED) {
      ActivityCompat.requestPermissions(this.activity, new String[]{Manifest.permission.READ_CONTACTS}, PERMISSIONS_REQUEST_READ_CONTACTS);
      //After this point you wait for callback in onRequestPermissionsResult(int, String[], int[]) overriden method
    } else {
      // Android version is lesser than 6.0 or the permission is already granted.
      return getContactNames();
    }

    return null;
  }

  private ImmutableMap<String, Object> getContactNames() {
    ImmutableList.Builder<ImmutableMap<String, Object>> providerDataBuilder =
            ImmutableList.<ImmutableMap<String, Object>>builder();
    ContentResolver resolver = this.activity.getApplicationContext().getContentResolver();
    Log.i(TAG, "Getting cursor.....");
    Cursor cur = resolver.query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI, null,null,null, ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME+" ASC");

    if ((cur != null ? cur.getCount() : 0) > 0) {
      while (cur != null && cur.moveToNext()) {
        ImmutableMap.Builder<String, Object> builder = ImmutableMap.<String, Object>builder();
        String name=cur.getString(cur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
        String phoneNo = cur.getString(cur.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
        builder.put("name", name);
        builder.put("phoneNumber", phoneNo);
        //Log.i(TAG, "Name: " + name);
        //Log.i(TAG, "Phone Number: " + phoneNo);
        providerDataBuilder.add(builder.build());
      }

    }
    if(cur!=null){
      cur.close();
    }

    ImmutableMap<String, Object> userMap = ImmutableMap.<String, Object>builder()
            .put("contacts", providerDataBuilder.build())
            .build();
    return userMap;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getContacts")) {
      ImmutableMap<String, Object> userMap = showContacts();
      result.success(userMap);
    } else if(call.method.equals("setLandscape")) {
      this.activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
      result.success("landscape");
    } else if(call.method.equals("setPortrait")) {
      this.activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
      result.success("portrait");
    } else {
      result.notImplemented();
    }
  }

  public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                         int[] grantResults) {
    if (requestCode == PERMISSIONS_REQUEST_READ_CONTACTS) {
      if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        // Permission is granted
        showContacts();
      }
    }
  }
}
