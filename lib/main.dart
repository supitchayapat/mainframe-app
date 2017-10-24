import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/MainFrameRoute.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_database/firebase_database.dart';

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
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamed(_nextRoute);
          });
        }
      });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(title: new Text("Main Frame Dance Studio")),
      body: new Container(
        //color: Colors.amber,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Padding(padding: new EdgeInsets.all(6.0)),
            new RaisedButton(
                child: new Text("Connect with Facebook"),
                color: Colors.blue,
                onPressed: () {
                  signInWithFacebook().then((str) => Navigator.of(context).pushNamed(_nextRoute));
                  _nextRoute = "/profilesetup-1";
                }
            ),
            new Padding(padding: new EdgeInsets.all(6.0)),
            new RaisedButton(
                child: new Text("Connect with Google"),
                color: Colors.red,
                onPressed: () {
                  signInWithGoogle();
                  Navigator.pushNamed(context, '/profilesetup-1');
                }
            ),
            new Padding(padding: new EdgeInsets.all(6.0)),
            new RaisedButton(
                child: new Text("Sign-up Email"),
                color: Colors.red,
                onPressed: () {
                  Navigator.pushNamed(context, '/emailRegistry');
                }
            )
          ],
        ),
      ),
    );
  }
}
