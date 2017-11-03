import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/screen/main_drawer.dart';
import 'package:myapp/src/widget/EventsTile.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //ThemeData theme = Theme.of(context);
    ThemeData theme = new ThemeData(
        primaryColor: new Color(0xFF324261),
        fontFamily: "Montserrat-Regular",
        canvasColor: new Color(0xFF324261)
    );
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: new Scaffold(
        key: _scaffoldKey,
        drawer: new MainFrameDrawer(_scaffoldKey),
        appBar: new AppBar(
          title: new Text("Event"),
          automaticallyImplyLeading: false,
          leading: new IconButton(
              icon: const Icon(Icons.menu),
              onPressed: _menuPressed
          ),
        ),
        backgroundColor: const Color(0xFF324261),
        body: new Container(
          margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: new Column(
            children: <Widget>[
              new Container(
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new ExactAssetImage("mainframe_assets/images/m7x5ba.jpg"),
                        fit: BoxFit.cover
                    )
                ),
                child: new Container(
                  height: 55.0,
                  width: 200.0,
                  child: new Text("Find Your Next Event Below",
                    style: new TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0
                    ),
                  ),
                ),
                height: 235.0,
                width: 360.0,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
              ),

              new Container(
                //color: Colors.amber,
                  height: 275.0,
                  child: new ListView(
                    children: <Widget>[
                      new ClipRect(
                          child: new Stack(
                            children: <Widget>[
                              new Container(
                                  child: new Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        // list items
                                        new EventsListTile(
                                          leading: new SizedBox(
                                            height: 75.0,
                                            width: 140.0,
                                            child: new Image.network("http://i67.tinypic.com/63x7qe.png"),
                                          ),
                                          title: new Text("American Star Ball", style: new TextStyle(color: Colors.white)),
                                          subtitle: new Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Text("May 18", style: new TextStyle(color: new Color(0xff00e5ff))),
                                              new Text("2017", style: new TextStyle(color: new Color(0xff00e5ff)))
                                            ],
                                          ),
                                          trailing: new Image.network("http://i67.tinypic.com/1zclu7t.jpg",
                                            height: 50.0,
                                            width: 50.0,
                                          ),
                                        ),
                                        new EventsListTile(
                                          leadingColor: const Color(0xff0072b9),
                                          leading: new SizedBox(
                                            height: 75.0,
                                            width: 140.0,
                                            child: new Image.network("http://i64.tinypic.com/561px.png"),
                                          ),
                                          title: new Text("Commonwealth Classic", style: new TextStyle(color: Colors.white)),
                                          subtitle: new Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Text("November 3 - 5", style: new TextStyle(color: new Color(0xff00e5ff))),
                                              new Text("2017", style: new TextStyle(color: new Color(0xff00e5ff)))
                                            ],
                                          ),
                                        ),
                                        new EventsListTile(
                                          leadingColor: const Color(0xff3e2054),
                                          leading: new SizedBox(
                                            height: 75.0,
                                            width: 140.0,
                                            child: new Image.network("http://i65.tinypic.com/wrhw9h.png"),
                                          ),
                                          title: new Text("Golden Star Dance Championship", style: new TextStyle(color: Colors.white)),
                                          subtitle: new Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Text("January 27 - 29", style: new TextStyle(color: new Color(0xff00e5ff))),
                                              new Text("2017", style: new TextStyle(color: new Color(0xff00e5ff)))
                                            ],
                                          ),
                                          trailing: new Image.network("http://i67.tinypic.com/1zclu7t.jpg",
                                            height: 50.0,
                                            width: 50.0,
                                          ),
                                        ),
                                        new EventsListTile(
                                          leading: new SizedBox(
                                            height: 75.0,
                                            width: 140.0,
                                            child: new Image.network("http://i67.tinypic.com/15pk9ec.png"),
                                          ),
                                          title: new Text("Paragon Open Dancesport Championship", style: new TextStyle(color: Colors.white, fontSize: 15.5)),
                                          subtitle: new Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Text("October 26 - 29", style: new TextStyle(color: new Color(0xff00e5ff))),
                                              new Text("2017", style: new TextStyle(color: new Color(0xff00e5ff)))
                                            ],
                                          ),
                                        ),
                                        new EventsListTile(
                                          leadingColor: Colors.black,
                                          leading: new SizedBox(
                                            height: 75.0,
                                            width: 140.0,
                                            child: new Image.network("http://i65.tinypic.com/a41imq.png"),
                                          ),
                                          title: new Text("Manhattan Dancesport Championship", style: new TextStyle(color: Colors.white)),
                                          subtitle: new Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Text("Jun 23 - Jul 3", style: new TextStyle(color: new Color(0xff00e5ff))),
                                              new Text("2017", style: new TextStyle(color: new Color(0xff00e5ff)))
                                            ],
                                          ),
                                        ),
                                      ]
                                  )
                              ),
                            ],
                          )
                      )
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}