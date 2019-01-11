import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/dao/DeviceInfoDao.dart';
import 'package:myapp/src/util/TimerUtil.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var listener = null;
  String _nextRoute = "/mainscreen"; // if user is logged-in
  String _str = "";
  Timer verTimer;

  void _signInEmailPressed() {
    print("Listener CANCELLED");
    //listener.cancel();
    Navigator.pushNamed(context, "/emailLogin");
  }

  void _signInFacebookPressed() {
    MainFrameLoadingIndicator.showLoading(context);

    DeviceInfoDao.updateStatus("Clicked Login via FB");

    signInWithFacebook().then((str) {
          /*MFHttpUtil.requestFacebookFriends().then((users){
            global.setTaggableFriends = users;
          });*/

          DeviceInfoDao.updateStatus("Facebook API Returned");

          if(str == "success") {
              // save device platform and version
              print("Saving device[${global.devicePlatform}] and version[${global.app_version}]");
              saveUserLogin(global.devicePlatform, global.app_version);
              DeviceInfoDao.updateStatus("Successful Facebook Login");
              Navigator.of(context).pushReplacementNamed(_nextRoute);
          }
          else if(str == "new-user" || str == "failed") {
            _nextRoute = "/profilesetup-1";
            DeviceInfoDao.updateStatus("New User Login. Waiting for User Creation on RTDB");
            newUserListener((event){
              DeviceInfoDao.updateStatus("New User sucessfully created on RTDB");
              // save device platform and version
              print("Saving device[${global.devicePlatform}] and version[${global.app_version}]");
              saveUserLogin(global.devicePlatform, global.app_version).then((_loginState){
                Navigator.of(context).pushReplacementNamed(_nextRoute);
                if(listener != null) {
                  listener.cancel();
                }
              });
            }).then((sub){ listener = sub; }).timeout(new Duration(seconds: 20), onTimeout: (){
              MainFrameLoadingIndicator.hideLoading(context);
              DeviceInfoDao.updateStatus("New User Failed to create RTDB data");
              print("Reqest has timed out");
              showMainFrameDialog(context, "Error", "Could not connect to facebook.");
              logoutUser();
            });
          }
        })
        .catchError((err) {
      print('SIGN UP ERROR.... $err type: ${err.runtimeType}');
      //MainFrameLoadingIndicator.hideLoading(context);
      Navigator.of(context).maybePop();
      if(err is AssertionError) {
        //if(err.message.toString().toLowerCase().contains("accesstoken")){
        print("did not FB authenticate");
        DeviceInfoDao.updateStatus("User Did not Authenticate FB");
      } else {
        // send crash report
        //showMainFrameDialog(context, "Application Error", "An error occurred during the process. ${err.message}");
        DeviceInfoDao.updateStatus("And error has occurred. FB did not Authenticate");
      }

      // reload
      Navigator.of(context).pushReplacementNamed("/");
    });
    _nextRoute = "/mainscreen";
  }

  @override
  void initState() {
    super.initState();

    verTimer = new Timer(new Duration(seconds: 10), () => TimerUtil.timerCheckVersion(context, verTimer));

    // check user logged in
    /*listener = initAuthStateListener((bool isLogged) {
      print("[Main page] Is loggedin: $isLogged");
      if(isLogged) {
        MainFrameLoadingIndicator.hideLoading(context);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(_nextRoute);
        });
      }
    });*/
  }

  @override
  void dispose() {
    print("DISPOSED LOGIN");
    super.dispose();
    //listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                    alignment: Alignment.center,
                    //color: Colors.amber,
                    height: 250.0,
                    /*child: new Text(
                "Logo Placeholder",
                style: new TextStyle(fontSize: 15.0, color: Colors.white, fontFamily: "Montserrat-Light")
            ),*/
                    child: new Image(
                        image: new AssetImage("mainframe_assets/images/BallroomGo.png")
                    )
                ),
                new Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20.0),
                  child: new MainFrameButton(
                    child: new Text("LOGIN VIA FACEBOOK"),
                    onPressed: _signInFacebookPressed,
                  ),
                ),
                // DISABLED UNTIL NEXT RELEASE
                /*new Container(
                  //color: Colors.amber,
                    height: 80.0,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20.0),
                    child: new MaterialButton(
                      onPressed: _signInEmailPressed,
                      child: new Text(
                          "Sign Up or Login via Email",
                          style: new TextStyle(fontSize: 15.0, color: Colors.white, fontFamily: "Montserrat-Light")
                      ),
                    )
                ),*/
              ],
            )
          ),
          new Container(
            padding: const EdgeInsets.all(20.0),
            height: 120.0,
            alignment: Alignment.center,
            child: new Image(
                //image: new AssetImage("mainframe_assets/images/powered_by_2x.png")
                image: new AssetImage("mainframe_assets/images/DanceFrame-logo.png")
            )
          )
        ],
      ),
    );
  }
}