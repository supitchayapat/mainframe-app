import 'package:flutter/material.dart';
import 'EventsTile.dart';
import 'package:myapp/src/screen/main_drawer.dart';
import 'package:myapp/src/dao/EventDao.dart';

class EventsWidget extends StatefulWidget {
  @override
  _EventsWidgetState createState() => new _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  MainFrameDrawer _mainFrameDrawer;
  List<EventsListTile> listTiles = <EventsListTile>[];

  void _menuPressed() {
    _scaffoldKey.currentState.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    EventDao.getEvents().then((events) {
      setState(() {
        for(var e in events) {
          listTiles.add(
              new EventsListTile(
                leadingColor: e.thumbnailBg != null ? new Color(int.parse(e.thumbnailBg)) : new Color(0xffffffff),
                leading: new SizedBox(
                  height: 75.0,
                  width: 140.0,
                  child: new Image.network(e.thumbnail),
                ),
                title: new ListTileText(e.eventTitle),
                subtitle: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(e.dateRange, style: new TextStyle(color: new Color(0xff00e5ff))),
                    new Text(e.year.toString(), style: new TextStyle(color: new Color(0xff00e5ff)))
                  ],
                ),
                trailing: e.hasAttended ? new Image.network("http://i67.tinypic.com/1zclu7t.jpg",
                  height: 50.0,
                  width: 50.0,
                ) : new Container(),
              )
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
            new Expanded(
                child: new Container(
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
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                )
            ),

            new Flexible(
                //color: Colors.amber,
                //height: 275.0,
                child: new ListView(
                  children: <Widget>[
                    new ClipRect(
                        child: new Stack(
                          children: <Widget>[
                            new Container(
                                child: new Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: listTiles
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
    );
  }
}