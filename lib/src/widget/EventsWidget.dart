import 'package:flutter/material.dart';
import 'EventsTile.dart';
import 'package:myapp/src/screen/main_drawer.dart';
import 'package:myapp/src/dao/EventDao.dart';
import 'package:myapp/src/util/FileUtil.dart';
import 'package:myapp/src/screen/event_details.dart' as eventInfo;

class EventsWidget extends StatefulWidget {
  @override
  _EventsWidgetState createState() => new _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {
  var listener;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  MainFrameDrawer _mainFrameDrawer;
  List<Widget> listTiles = <Widget>[];

  void _menuPressed() {
    _scaffoldKey.currentState.openDrawer();
  }

  void _handleEventTap(event) {
    eventInfo.eventItem = event;
    Navigator.of(context).pushNamed("/eventInfo");
  }

  @override
  void initState() {
    super.initState();

    listener = EventDao.eventsListener((events) {
      FileUtil.getImages().then((lst) {
        setState(() {
          listTiles = <Widget>[];
          int ctr = 0;
          for (var e in events) {
            //print("CTR === $ctr");
            Widget imgThumb;
            if(ctr < lst.length)
              imgThumb = lst[ctr++];
            /*FileUtil.getImage(e.thumbnail).then((imgItem){
            imgThumb = imgItem;
          });*/

            listTiles.add(
                new InkWell(
                  onTap: () { _handleEventTap(e); },
                  child: new EventsListTile(
                    leadingColor: e.thumbnailBg != null ? new Color(
                        int.parse(e.thumbnailBg)) : Theme.of(context).primaryColor,
                    leading: new SizedBox(
                        height: 78.0,
                        width: 140.0,
                        //child: new Image.network(e.thumbnail),
                        child: imgThumb != null ? imgThumb : new Container()
                    ),
                    title: new ListTileText(e.eventTitle),
                    subtitle: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(e.dateRange,
                            style: new TextStyle(color: new Color(0xff00e5ff))),
                        new Text(e.year.toString(),
                            style: new TextStyle(color: new Color(0xff00e5ff)))
                      ],
                    ),
                    trailing: e.hasAttended ? new Image.asset(
                      "mainframe_assets/images/attended_before@2x.png",
                      height: 60.0,
                      width: 60.0,
                    ) : new Container(),
                  )
                )
            );
          }
        });
      });
    });
  }

  @override
  void dispose() {
    print("DISPOSED EVENTS WIDGET");
    super.dispose();
    listener.cancel();
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