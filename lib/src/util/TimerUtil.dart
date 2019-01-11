import 'dart:async';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/MFGlobals.dart' as global;

class TimerUtil {

  static Future timerCheckVersion(context, verTimer) async {
    String redirectUri = "";
    if(global.devicePlatform == "android") {
      redirectUri = "https://play.google.com/store/apps/details?id=com.danceframe.ballroomgo"; // https://play.google.com/store/apps/details?id=<package_name>
    }
    else {
      redirectUri = "http://itunes.apple.com"; // http://itunes.apple.com/<country>/app/<app–name>/id<app-ID>?mt=8
    }
    String confAppVer = global.app_version.substring(0, global.app_version.lastIndexOf("."));

    if(!global.conf_version.isEmpty && !global.app_version.isEmpty && confAppVer != global.conf_version) {
      print("SHOWING ALERT MESSAGE BOX");
      showMainFrameDialog(
          context,
          "UPDATE",
          "New Update of the application was released. Please download the latest one",
          uriRedirect: redirectUri
      );
      verTimer.cancel();
    }
  }
}