import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';

class MainScreen extends StatelessWidget {

  void _logout() {
    logoutUser();
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text("Main Frame Dance Studio"), automaticallyImplyLeading: false),
        body: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Padding(padding: new EdgeInsets.all(6.0)),
              new Text("<<< MAIN SCREEN >>>"),
              new Padding(padding: new EdgeInsets.all(6.0)),
              new RaisedButton(
                  child: new Text("Logout"),
                  color: Colors.red,
                  onPressed: () {
                    _logout();
                    Navigator.of(context).pushReplacementNamed("/");
                  }
              )
            ],
          ),
        )
    );
  }
}