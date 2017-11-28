package com.yourcompany.facebooksignin;

import android.app.Activity;
import android.content.Intent;
import android.support.annotation.NonNull;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;

import java.util.Arrays;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FacebookSignInPlugin
 */
public class FacebookSignInPlugin implements MethodCallHandler,
        PluginRegistry.ActivityResultListener {

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "facebook_sign_in");
    final FacebookSignInPlugin instance = new FacebookSignInPlugin(registrar.activity());
    registrar.addActivityResultListener(instance);
    channel.setMethodCallHandler(instance);
  }


  private Activity activity;
  //private AccessToken token;
  private CallbackManager callbackManager = CallbackManager.Factory.create();

  private FacebookSignInPlugin(Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (call.method.equals("loginWithReadPermissions")) {
      //FacebookSdk.sdkInitialize(activity);
      LoginManager.getInstance().registerCallback(callbackManager, getCallback(result));
      List<String> permissions = call.argument("permissions");
      LoginManager.getInstance().logInWithReadPermissions(this.activity, permissions);
    } else if (call.method.equals("loginWithPublishPermissions")) {
      //FacebookSdk.sdkInitialize(activity);
      LoginManager.getInstance().registerCallback(callbackManager, getCallback(result));
      List<String> permissions = call.argument("permissions");
      LoginManager.getInstance().logInWithPublishPermissions(this.activity, permissions);
    } else if (call.method.equals("logout")) {
      LoginManager.getInstance().logOut();
      result.success("Logged out");
    } else if (call.method.equals("isLoggedIn")) {
      AccessToken currentToken = AccessToken.getCurrentAccessToken();
      if (currentToken == null)
        result.success(false);
      else
        result.success(true);
    } else if (call.method.equals("getToken")) {
      AccessToken currentToken = AccessToken.getCurrentAccessToken();
      if (currentToken == null)
        result.error("UNAVAILABLE", "No token available, is the user logged in?", null);
      else
        result.success(currentToken.getToken());
    } else {
      result.notImplemented();
    }
  }

  @NonNull
  private FacebookCallback<LoginResult> getCallback(final Result result) {
    return new FacebookCallback<LoginResult>() {
      @Override
      public void onSuccess(LoginResult loginResult) {
        AccessToken token = loginResult.getAccessToken();
        result.success(token.getToken());
      }

      @Override
      public void onCancel() {
        result.error("UNAVAILABLE", "User discontinued login process.", null);
      }

      @Override
      public void onError(FacebookException error) {
        result.error("Facebook Login Error", error.getMessage(), error);
      }
    };
  }

  @Override
  public boolean onActivityResult(int i, int i1, Intent intent) {
    callbackManager.onActivityResult(i, i1, intent);
    return false;
  }
}