import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:mframe_plugins/mframe_plugins.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class MainFrameSplash extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  MainFrameSplash({this.analytics, this.observer});

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

    // set portrait mode
    MframePlugins.setToPortrait();

    MframePlugins.platform.then((_platform){
      print("CURRENT PLATFORM: ${_platform}");
      if(_platform != null)
        global.devicePlatform = _platform;
    });

    // set firebase instance offline
    //FirebaseDatabase.instance.setPersistenceEnabled(true);

    // check user logged in
    listener = initAuthStateListener((bool isLogged) {
      print("[SPLASH page] Is loggedin: $isLogged");
      String _navi = '/mainscreen';
      if(!isLogged) {
        _navi = '/loginscreen';
      }
      //else {
        //FileUtil.loadImages();
      //}
      //SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(_navi);
      //});

    });
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