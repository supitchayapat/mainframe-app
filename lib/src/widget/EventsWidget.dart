import 'package:flutter/material.dart';
import 'EventsTile.dart';
import 'package:myapp/src/screen/main_drawer.dart';
import 'package:myapp/src/dao/EventDao.dart';
import 'package:myapp/src/util/FileUtil.dart';
import 'package:myapp/src/screen/event_details.dart' as eventInfo;

const double _kFlexibleSpaceMaxHeight = 186.0;

class EventsWidget extends StatefulWidget {
  @override
  _EventsWidgetState createState() => new _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {
  var listener;
  var past_listener;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  MainFrameDrawer _mainFrameDrawer;
  List<Widget> listTiles = <Widget>[];
  List _events = [];
  List _pastEvents = [];
  Map<String, Widget> _thumbImages = {};

  void _menuPressed() {
    _scaffoldKey.currentState.openDrawer();
  }

  void _handleEventTap(event) {
    eventInfo.eventItem = event;
    Navigator.of(context).pushNamed("/eventInfo");
  }

  void _buildListTiles() {
    listTiles = [];
    _renderEvents();
  }

  void _renderEvents() {
    double scrnWidth = MediaQuery.of(context).size.width;

    _events.forEach((e){
      //print(e.thumbnail);
      double _padd = 0.0;
      double _width = scrnWidth;//100.0;
      //print("${e.eventTitle} >> ${e.eventTitle.length}");
      if(e.eventTitle.length >= 46) {
        _padd = 10.0;
        _width = 60.0;
      }

      listTiles.add(
          new InkWell(
              onTap: () {
                _handleEventTap(e);
              },
              child: new EventsListTile(
                leadingColor: e.thumbnailBg != null ? new Color(
                    int.parse(e.thumbnailBg)) : Theme
                    .of(context)
                    .primaryColor,
                leading: new SizedBox(
                    height: 78.0,
                    width: 140.0,
                    //child: new Image.network(e.thumbnail),
                    child: (_thumbImages != null && _thumbImages.containsKey(e.thumbnail)) ? _thumbImages[e.thumbnail] : new Container()
                ),
                title: new Container(
                    //color: Colors.amber,
                    alignment: Alignment.centerLeft,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          //color: Colors.amber,
                          constraints: new BoxConstraints(maxHeight: 50.0),
                          child: new ListTileText(e.eventTitle),
                        ),
                        new Wrap(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(e.dateRange,
                                style: new TextStyle(color: new Color(0xff00e5ff))),
                            new Container(
                              //color: Colors.amber,
                              padding: new EdgeInsets.only(left: _padd),
                              width: _width,
                              //padding: const EdgeInsets.only(left: 20.0),
                              child: new Text(e.year.toString(),
                                  style: new TextStyle(color: new Color(0xff00e5ff))),
                            )
                          ],
                        ),
                      ],
                    ),
                    //child: new ListTileText(e.eventTitle)
                ),
                /*subtitle: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(e.dateRange,
                        style: new TextStyle(color: new Color(0xff00e5ff))),
                    new Text(e.year.toString(),
                        style: new TextStyle(color: new Color(0xff00e5ff)))
                  ],
                ),*/
                trailing: e.hasAttended ? new Image.asset(
                  "mainframe_assets/images/attended_before@2x.png",
                  height: 60.0,
                  width: 60.0,
                ) : new Container(),
              )
          )
      );

    });
  }

  @override
  void initState() {
    super.initState();

    listener = EventDao.eventsListener((events) {
      setState(() {
        print("set events");
        _events = [];
        _events.addAll(events);
        _buildListTiles();
      });
    });

    past_listener = EventDao.pastUserEventListener((events) {
      setState(() {
        print("past events LENGTH: ${events.length}");
        _events = [];
        _events.addAll(events);
        _buildListTiles();
      });
    });

    FileUtil.downloadImagesCallback((fileName, img){
      setState((){
        Image _img = new Image.file(img);
        _thumbImages.putIfAbsent(fileName, () => _img);
        _buildListTiles();
      });
    });
  }

  @override
  void dispose() {
    print("DISPOSED EVENTS WIDGET");
    super.dispose();
    listener.cancel();
    past_listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [];
    _children.add(new Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new ExactAssetImage(
                  "mainframe_assets/images/m7x5ba.jpg"),
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
    ));
    _children.addAll(listTiles);

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
        child: new ListView(
          children: _children
          /*children: <Widget>[
            //new Expanded(
                /*child:*/ new Container(
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: new ExactAssetImage(
                              "mainframe_assets/images/m7x5ba.jpg"),
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
                ),
            //),
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
                                    crossAxisAlignment: CrossAxisAlignment
                                        .stretch,
                                    children: listTiles
                                )
                            ),
                          ],
                        )
                    )
                  ],
                )
            )
          ],*/
        ),
      ),
    );
  }
}
  /*@override
  Widget build(BuildContext context) {

    // TODO: implement build
    return new Scaffold(
      drawer: new MainFrameDrawer(_scaffoldKey),
      body: new CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            pinned: true,
            expandedHeight: _kFlexibleSpaceMaxHeight,
            flexibleSpace: const FlexibleSpaceBar(
              title: const Text('Events'),
              // TODO(abarth): Wire up to the parallax in a way that doesn't pop during hero transition.
              background: const _AppBarBackground(animation: kAlwaysDismissedAnimation),
            ),
          ),
          new SliverList(delegate: new SliverChildListDelegate(listTiles)),
        ],
      ),
    );
  }
}*/

/*class _BackgroundLayer {
  _BackgroundLayer({ int level, double parallax })
      : assetName = "mainframe_assets/images/m7x5ba.jpg",
        parallaxTween = new Tween<double>(begin: 0.0, end: parallax);
  final String assetName;
  final Tween<double> parallaxTween;
}

final List<_BackgroundLayer> _kBackgroundLayers = <_BackgroundLayer>[
  new _BackgroundLayer(level: 0, parallax: _kFlexibleSpaceMaxHeight),
  new _BackgroundLayer(level: 1, parallax: _kFlexibleSpaceMaxHeight),
  new _BackgroundLayer(level: 2, parallax: _kFlexibleSpaceMaxHeight / 2.0),
  new _BackgroundLayer(level: 3, parallax: _kFlexibleSpaceMaxHeight / 4.0),
  new _BackgroundLayer(level: 4, parallax: _kFlexibleSpaceMaxHeight / 2.0),
  new _BackgroundLayer(level: 5, parallax: _kFlexibleSpaceMaxHeight)
];

class _AppBarBackground extends StatelessWidget {
  const _AppBarBackground({ Key key, this.animation }) : super(key: key);

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return new Stack(
              children: _kBackgroundLayers.map((_BackgroundLayer layer) {
                return new Positioned(
                    top: -layer.parallaxTween.evaluate(animation),
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: new Image.asset(
                        layer.assetName,
                        fit: BoxFit.cover,
                        height: _kFlexibleSpaceMaxHeight
                    )
                );
              }).toList()
          );
        }
    );
  }
}*/