import 'package:flutter/material.dart';
import 'package:myapp/src/widget/EventsWidget.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_dynamic_link/firebase_dynamic_link.dart';
import 'package:myapp/src/dao/EventDao.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:mframe_plugins/mframe_plugins.dart';
import 'package:myapp/src/screen/event_details.dart' as eventInfo;
import 'package:myapp/MFGlobals.dart' as global;

class MainScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => new _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var remove_listener;

  /*void _logout() {
    logoutUser();
    Navigator.popUntil(context, (_) => !Navigator.canPop(context));
    Navigator.of(context).pushNamed("/");
  }*/

  @override
  void initState() {
    super.initState();
    /*getCurrentUserProfile().then((usr) {
      //_mainFrameDrawer = new MainFrameDrawer(_scaffoldKey);
      MainFrameDrawer.currentUser=usr;
    });*/

    MframePlugins.platform.then((_platform){
      if(_platform != null)
        global.devicePlatform = _platform;
    });

    getCurrentUserProfile().then((_usr){
      global.currentUserProfile = _usr;
    });

    // load FB Friends
    global.taggableFriends.then((val){});

    // get dynamic link with firebase
    FirebaseDynamicLink.getDynamicLink().then((String _link){
      if(_link != null) {
        if(_link.contains("/")) {
          List<String> nav = _link.split("/");
          if(nav.length > 2) {
            String _navId = nav[2];
            EventDao.getEvent(nav[2]).then((evt){
              eventInfo.eventItem = evt;
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushNamed("/${nav[1]}");
              });
            });
          }
        }
      }
    }).catchError((error){
      print("Error: $error");
    });

    // check user is deleted on firebase console
    remove_listener = removeUserListener((event){
      logoutUser();
      String _navi = "/loginscreen";
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(_navi);
      });
    });
  }

  @override
  void dispose() {
    print("DISPOSED SPLASH");
    super.dispose();
    remove_listener.cancel();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //ThemeData theme = Theme.of(context);
    ThemeData theme = new ThemeData(
        primaryColor: new Color(0xFF324261),
        fontFamily: "Montserrat-Regular",
        canvasColor: new Color(0xFF324261)
    );
    /*return new MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: new EventsWidget(),
    );*/
    return new EventsWidget();
  }
}