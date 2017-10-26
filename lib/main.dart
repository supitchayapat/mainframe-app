import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/MainFrameRoute.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/src/demo/demo.dart';
import 'src/util/ScreenUtils.dart';
import 'src/util/LoadingIndicator.dart';


void main() {
  runApp(new MaterialApp(
      home: new MyApp(),
      onGenerateRoute: getMainFrameRoute,
  ));
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _nextRoute = "/mainscreen"; // if user is logged-in

  @override
  void initState() {
      super.initState();
      // set firebase instance offline
      FirebaseDatabase.instance.setPersistenceEnabled(true);

      // check user logged in
      initAuthStateListener((bool isLogged) {
        print("[Main page] Is loggedin: $isLogged");
        if(isLogged) {
          MainFrameLoadingIndicator.hideLoading(context);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamed(_nextRoute);
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
              new Padding(padding: new EdgeInsets.all(6.0)),
              new RaisedButton(
                  child: new Text("Facebook Login"),
                  color: Colors.blue,
                  onPressed: () {
                    MainFrameLoadingIndicator.showLoading(context);
                    loginWithFacebook().then((str) =>
                        Navigator.of(context).pushNamed(_nextRoute))
                        .catchError((err) {
                      print('SIGN UP ERROR.... $err');
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
                    MainFrameLoadingIndicator.showLoading(context);
                    signInWithFacebook().then((str) =>
                        Navigator.of(context).pushNamed(_nextRoute))
                        .catchError((err) {
                          print('SIGN UP ERROR.... $err');
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
