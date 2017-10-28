import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/screen/main_drawer.dart';
import 'package:myapp/src/dao/UserDao.dart';

class MainScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => new _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  MainFrameDrawer _mainFrameDrawer;

  void _logout() {
    logoutUser();
    Navigator.popUntil(context, (_) => !Navigator.canPop(context));
    Navigator.of(context).pushNamed("/");
  }

  void _menuPressed() {
    //if(MainFrameDrawer.currentUser != null) {
      _scaffoldKey.currentState.openDrawer();
    //}
  }

  @override
  void initState() {
    super.initState();
    /*getCurrentUserProfile().then((usr) {
      //_mainFrameDrawer = new MainFrameDrawer(_scaffoldKey);
      MainFrameDrawer.currentUser=usr;
    });*/
  }
  
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      theme: new ThemeData(
        //primaryColor: new Color(0xFF2c3b54),
        canvasColor: new Color(0xFF324261)
      ),
      home: new Scaffold(
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
                      //Navigator.of(context).pushNamedAndRemoveUntil("/", (_) => false);
                    }
                )
              ],
            ),
          ),

          drawer: new MainFrameDrawer(_scaffoldKey)
      ),
    );
  }
}