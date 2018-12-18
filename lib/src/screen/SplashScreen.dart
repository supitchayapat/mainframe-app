import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:mframe_plugins/mframe_plugins.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:myapp/src/screen/change_password.dart' as cp;
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:myapp/src/dao/DeviceInfoDao.dart';
import 'package:myapp/src/enumeration/LogMessage.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'dart:convert' show json;

class MainFrameSplash extends StatefulWidget {

  @override
  _MainFrameSplashState createState() => new _MainFrameSplashState();
}

class _MainFrameSplashState extends State<MainFrameSplash> {
  var listener;

  @override
  void initState() {
    super.initState();

    // logging for crashlytics
    // CrashlyticsReport.logMessage("Splash Screen Page load");
    global.messageLogs.add("Splash Screen Page Load.");
    AnalyticsUtil.setCurrentScreen("Splash Screen", screenClassName: "SplashScreen");

    // set portrait mode
    MframePlugins.setToPortrait();

    MframePlugins.platform.then((_platform){
      print("CURRENT PLATFORM: ${_platform}");
      if(_platform != null) {
        global.devicePlatform = _platform;
        global.getDevicePushId().then((_pId){
          print("IS PID PRESENT: ${_pId}");
          if(_pId == null) {
            DeviceInfoDao.saveDeviceInfo("Loaded Application").then((pushId){
              print("PUSH ID: ${pushId}");
              global.setDevicePushId(pushId);
              //print("GET PUSH ID = ${global.getDevicePushId()}");
            });
          } else {
            DeviceInfoDao.updateStatus("Loaded Application");
          }
        });
      }
    });

    rootBundle.loadString('mainframe_assets/conf/config.json').then<Null>((String data) {
      if(data != null) {
        var result = json.decode(data);
        global.app_version = result['app_version'];
      }
    });

    // set firebase instance offline
    //FirebaseDatabase.instance.setPersistenceEnabled(true);

    // check user logged in
    listener = initAuthStateListener((bool isLogged) {
      print("[SPLASH page] Is loggedin: $isLogged");
      String _navi = '/mainscreen';
      if(!isLogged) {
        //_navi = '/loginscreen';
        _retrieveDynamicLink().then((retVal) {
          Navigator.of(context).pushReplacementNamed(retVal);
        });
      }
      else {
        getCurrentUserProfile().then((_usr){
          if(_usr?.testUser != null) {
            global.testUserFlag = _usr.testUser;
          }
          Navigator.of(context).pushReplacementNamed(_navi);
        });
      }
      //else {
        //FileUtil.loadImages();
      //}
      //SchedulerBinding.instance.addPostFrameCallback((_) {
      //});

    });
  }

  Future<String> _retrieveDynamicLink() async {
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.retrieveDynamicLink();
    final Uri deepLink = data?.link;

    if(deepLink != null && deepLink.path.contains("changepass")) {
      if(deepLink.queryParameters.containsKey("tokenId")) {
        cp.changepassToken = deepLink.queryParameters["tokenId"];
        return '/change-password';
      }
    }

    return '/loginscreen';
  }

  @override
  void dispose() {
    print("DISPOSED SPLASH");
    super.dispose();
    listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(
              child: new Container(
                alignment: Alignment.center,
                //padding: const EdgeInsets.all(20.0),
                //height: 120.0,
                height: 250.0,
                child: new Image(
                    //image: new ExactAssetImage("mainframe_assets/images/Mainframe_Dance_System_Logo.png")
                    image: new ExactAssetImage("mainframe_assets/images/DanceFrame-logo.png")
                ),
              )
          )
        ],
      ),
    );
  }
}