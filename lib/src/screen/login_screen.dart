import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var listener = null;
  String _nextRoute = "/mainscreen"; // if user is logged-in

  void _signInEmailPressed() {
    print("Listener CANCELLED");
    //listener.cancel();
    Navigator.pushNamed(context, "/emailLogin");
  }

  void _signInFacebookPressed() {
    MainFrameLoadingIndicator.showLoading(context);
    signInWithFacebook().then((str) {
          /*MFHttpUtil.requestFacebookFriends().then((users){
            global.setTaggableFriends = users;
          });*/
          if(str == "success") {
            Navigator.of(context).pushReplacementNamed(_nextRoute);
          }
          else if(str == "new-user") {
            _nextRoute = "/profilesetup-1";
            newUserListener((event){
              //print("printing event data");
              Navigator.of(context).pushReplacementNamed(_nextRoute);
              if(listener != null) {
                listener.cancel();
              }
            }).then((sub){ listener = sub; });
          }
        })
        .catchError((err) {
      print('SIGN UP ERROR.... $err type: ${err.runtimeType}');
      //MainFrameLoadingIndicator.hideLoading(context);
      Navigator.of(context).maybePop();
      if(err is AssertionError) {
        //if(err.message.toString().toLowerCase().contains("accesstoken")){
        print("did not FB authenticate");
      } else {
        // send crash report
        //showMainFrameDialog(context, "Application Error", "An error occurred during the process. ${err.message}");
      }

      // reload
      Navigator.of(context).pushReplacementNamed("/");
    });
    _nextRoute = "/mainscreen";
  }

  @override
  void initState() {
    super.initState();
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
                new Container(
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
                ),
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