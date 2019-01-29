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
      redirectUri = "https://itunes.apple.com/us/app/ballroomgo/id1360103285?mt=8"; // http://itunes.apple.com/<country>/app/<app–name>/id<app-ID>?mt=8
    }
    String confAppVer = (global.app_version.contains(".")) ? global.app_version?.substring(0, global.app_version.lastIndexOf(".")) : ""; // strip dev
    confAppVer = (global.app_version.contains(".")) ? confAppVer.substring(0, confAppVer.lastIndexOf(".")) : ""; // strip date

    print("conf_ver: ${global.conf_version}");
    print("confAppVer: ${confAppVer}");

    if(!global.conf_version.isEmpty && !global.app_version.isEmpty && confAppVer != global.conf_version) {
      print("SHOWING ALERT MESSAGE BOX");
      showMainFrameDialog(
          context,
          "NEW UPDATE",
          "You are currently running version ${confAppVer}. A New Update of the application ver ${global.conf_version} was released. Please download the latest one. Thank you",
          uriRedirect: redirectUri
      );
      verTimer.cancel();
    }
  }
}