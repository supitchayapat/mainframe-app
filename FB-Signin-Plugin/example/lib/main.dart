// main.dart
//
// Example app for the Flutter Facebook Login plugin.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:facebook_sign_in/facebook_sign_in.dart'; // Import Facebook Login plugin.

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  /// Making permission lists to login.
  /// 
  /// The permissions that can be used can be found here: https://developers.facebook.com/docs/facebook-login/permissions/
  List<String> read = ["public_profile", "user_friends", "email"];
  List<String> publish = ["publish_actions"];

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Column(
          children: [
            new RaisedButton(
              child: new Text("Login with read permissions"),
              onPressed: () async {
                /// Login with read permissions.
                String token = await FacebookSignIn.loginWithReadPermissions(read);
                print("token: " + token);
              },
            ),
            new RaisedButton(
              child: new Text("Login with publish permissions"),
              onPressed: () async { 
                /// Login with publish permissions.
                String token = await FacebookSignIn.loginWithPublishPermissions(publish);
                print("token: " + token);
              },
            ),
            new RaisedButton(
              child: new Text("Check if logged in"),
              onPressed: () async { 
                /// Login with publish permissions.
                bool token = await FacebookSignIn.isLoggedIn();
                print("Logged in: " + token.toString());
              },
            ),
            new RaisedButton(
              child: new Text("Get token"),
              onPressed: () async { 
                /// Login with publish permissions.
                String token = await FacebookSignIn.getToken();
                print("token: " + token);
              },
            ),
            new RaisedButton(
              child: new Text("Logout"),
              onPressed: () async { 
                /// Logout the user.
                await FacebookSignIn.logout();
                print("Logged out!"); 
              },
            ),
          ]
        ),
      ),
    );
  }
  
}
