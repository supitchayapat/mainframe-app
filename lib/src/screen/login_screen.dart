import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:flutter/scheduler.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/util/ScreenUtils.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String _nextRoute = "/mainscreen"; // if user is logged-in

  void _signInEmailPressed() {
    Navigator.pushNamed(context, "/emailLogin");
  }

  void _signInFacebookPressed() {
    MainFrameLoadingIndicator.showLoading(context);
    loginWithFacebook().then((str) =>
        Navigator.of(context).pushReplacementNamed(_nextRoute))
        .catchError((err) {
      print('SIGN UP ERROR.... $err');
      MainFrameLoadingIndicator.hideLoading(context);
      showMainFrameDialog(context, "Application Error", "An error occurred during the process. $err.message");
    });
    _nextRoute = "/mainscreen";
  }

  @override
  void initState() {
    super.initState();

    // check user logged in
    initAuthStateListener((bool isLogged) {
      print("[Main page] Is loggedin: $isLogged");
      if(isLogged) {
        MainFrameLoadingIndicator.hideLoading(context);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(_nextRoute);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          new Container(
            alignment: Alignment.center,
            //color: Colors.amber,
            height: 250.0,
            child: new Text(
                "Logo Placeholder",
                style: new TextStyle(fontSize: 15.0, color: Colors.white, fontFamily: "Montserrat-Light")
            ),
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
          new Container(
            padding: const EdgeInsets.all(20.0),
            height: 120.0,
            alignment: Alignment.center,
            child: new Image(
                image: new AssetImage("mainframe_assets/images/powered_by_2x.png")
            )
          )
        ],
      ),
    );
  }
}