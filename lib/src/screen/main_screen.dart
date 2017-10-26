import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/screen/main_drawer.dart';
import 'package:myapp/src/dao/UserDao.dart';

class MainScreen extends StatelessWidget {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _logout() {
    logoutUser();
  }

  void _menuPressed() {
    _scaffoldKey.currentState.openDrawer();
  }
  
  @override
  Widget build(BuildContext context) {
    getCurrentUserProfile().then((usr) => MainFrameDrawer.currentUser=usr);

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
            title: new Text("Main Frame Dance Studio"), 
            automaticallyImplyLeading: false,
            leading: new IconButton(
                icon: const Icon(Icons.menu),
                onPressed: _menuPressed
            ),
        ),
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
                    Navigator.of(context).pushNamedAndRemoveUntil("/", (_) => false);
                  }
              )
            ],
          ),
        ),

        drawer: new MainFrameDrawer(_scaffoldKey)
    );
  }
}