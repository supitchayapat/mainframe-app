import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:flutter/scheduler.dart';
import 'package:myapp/src/demo/demo.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/MFGlobals.dart' as global;

class LoginApp extends StatefulWidget {

  @override
  _LoginAppState createState() => new _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _nextRoute = "/mainscreen"; // if user is logged-in

  @override
  void initState() {
    super.initState();

    // logging for crashlytics
    // CrashlyticsReport.logMessage("Login Page load");
    global.messageLogs.add("Login Page load");
    AnalyticsUtil.setCurrentScreen("Login Page", screenClassName: "login_a2");

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    Widget _buildLogin() {
      return new Scaffold(
        //appBar: new AppBar(title: new Text("Main Frame Dance Studio")),
        body: new Container(
          padding: new EdgeInsets.all(20.0),
          //color: Colors.amber,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //new Padding(padding: new EdgeInsets.all(6.0)),
              new RaisedButton(
                  child: new Text("Facebook Login"),
                  color: Colors.blue,
                  onPressed: () {
                    global.messageLogs.add("Facebook Login button pressed.");
                    AnalyticsUtil.sendAnalyticsEvent("fb_login_pressed", params: {
                      'screen': 'login_a2'
                    });
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
              ),
              new Padding(padding: new EdgeInsets.all(6.0)),
              new RaisedButton(
                  child: new Text("Email Login"),
                  color: Colors.red,
                  onPressed: () {
                    global.messageLogs.add("Email Login button pressed.");
                    AnalyticsUtil.sendAnalyticsEvent("email_login_pressed", params: {
                      'screen': 'login_a2'
                    });
                    _nextRoute = "/mainscreen";
                    Navigator.pushNamed(context, '/emailLogin');
                  }
              )
            ],
          ),
        ),
      );
    }

    Widget _buildSignUp() {
      return new Scaffold(
        key: _scaffoldKey,
        //appBar: new AppBar(title: new Text("Main Frame Dance Studio")),
        body: new Container(
          padding: new EdgeInsets.all(20.0),
          //color: Colors.amber,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Padding(padding: new EdgeInsets.all(6.0)),
              new RaisedButton(
                  child: new Text("Connect with Facebook"),
                  color: Colors.blue,
                  onPressed: () {
                    global.messageLogs.add("Facebook Login button pressed.");
                    AnalyticsUtil.sendAnalyticsEvent("fb_login_pressed", params: {
                      'screen': 'login_a2'
                    });
                    MainFrameLoadingIndicator.showLoading(context);
                    signInWithFacebook().then((str) =>
                        Navigator.of(context).pushNamed(_nextRoute))
                        .catchError((err) {
                      print('SIGN UP ERROR.... $err');
                      MainFrameLoadingIndicator.hideLoading(context);
                      showMainFrameDialog(context, "Application Error", "An error occurred during the process. $err.message");
                    });
                    _nextRoute = "/profilesetup-1";
                  }
              ),
              new Padding(padding: new EdgeInsets.all(6.0)),
              new RaisedButton(
                  child: new Text("Sign-up Email"),
                  color: Colors.red,
                  onPressed: () {
                    global.messageLogs.add("Email Login button pressed.");
                    AnalyticsUtil.sendAnalyticsEvent("email_login_pressed", params: {
                      'screen': 'login_a2'
                    });
                    _nextRoute = "/profilesetup-1";
                    Navigator.pushNamed(context, '/emailRegistry');
                  }
              )
            ],
          ),
        ),
      );
    }

    return new TabbedComponentDemoScaffold(
        hasBackButton: false,
        title: "Main Frame Dance Studio",
        demos: <ComponentDemoTabData>[
          new ComponentDemoTabData(
              tabName: 'LOG IN',
              description: '',
              demoWidget: _buildLogin()
          ),
          new ComponentDemoTabData(
              tabName: 'SIGN UP',
              description: '',
              demoWidget: _buildSignUp()
          )
        ]
    );
  }
}