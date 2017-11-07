import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:flutter/scheduler.dart';

class MainFrameSplash extends StatefulWidget {
  @override
  _MainFrameSplashState createState() => new _MainFrameSplashState();
}

class _MainFrameSplashState extends State<MainFrameSplash> {

  @override
  void initState() {
    super.initState();

    // set firebase instance offline
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    // check user logged in
    initAuthStateListener((bool isLogged) {
      print("[SPLASH page] Is loggedin: $isLogged");
      String _navi = '/mainscreen';
      if(!isLogged) {
        _navi = '/loginscreen';
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(_navi);
      });

    });
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
                padding: const EdgeInsets.all(60.0),
                child: new Image(
                    image: new ExactAssetImage("mainframe_assets/images/Mainframe_Dance_System_Logo.png")
                ),
              )
          )
        ],
      ),
    );
  }
}