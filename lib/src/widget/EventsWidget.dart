import 'dart:async';
import 'package:flutter/material.dart';
import 'EventsTile.dart';
import 'package:myapp/src/screen/main_drawer.dart';
import 'package:myapp/src/dao/EventDao.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/dao/ConfigDao.dart';
import 'package:myapp/src/util/FileUtil.dart';
import 'package:myapp/src/widget/MFTabComponent.dart';
import 'package:myapp/src/screen/event_details.dart' as eventInfo;
import 'package:myapp/MFGlobals.dart' as global;
import 'package:mframe_plugins/mframe_plugins.dart';
import 'package:myapp/src/util/PerformanceUtil.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';

const double _kFlexibleSpaceMaxHeight = 186.0;
const int _timerDelay = 100;
const int _refreshDelay = 1;

class EventsWidget extends StatefulWidget {
  @override
  _EventsWidgetState createState() => new _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {
  var listener;
  var past_listener;
  var ao_listener;
  var delete_listener;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  MainFrameDrawer _mainFrameDrawer;
  List<Widget> listTiles = <Widget>[];
  List<Widget> prevTiles = <Widget>[];
  List _events = [];
  List _pastEvents = [];
  Map<String, Widget> _thumbImages = {};
  bool eventListRunning = false;
  bool pastEventRunning = false;
  bool fileUtilRunning = false;
  Timer _performanceTimer;
  Timer _eventsListTimer;
  bool aoFlag;

  void _menuPressed() {
    _scaffoldKey.currentState.openDrawer();
  }

  void _handleEventTap(event) {
    eventInfo.eventItem = event;
    Navigator.of(context).pushNamed("/event");
  }

  void _buildListTiles() {
    listTiles = [];
    prevTiles = [];
    _renderEvents();
  }

  bool isStillRunning() {
    //print("eventList: $eventListRunning, pastEventRunning: $pastEventRunning, fileUtilRunning: $fileUtilRunning");
    if(eventListRunning || pastEventRunning || fileUtilRunning) {
      return true;
    }
    else {
      return false;
    }
  }

  void stopTracking() {
    _performanceTimer = new Timer.periodic(new Duration(milliseconds: _timerDelay), (timer){
      bool isRunning = isStillRunning();
      //print("IS RUNNING: $isRunning");
      if(!isRunning) {
        // stop performance check
        PerformanceUtil.stopTrace();
        // stop timer
        _performanceTimer.cancel();
        // clean images
        _cleanImages();
      }
    });
  }

  void _renderEvents() {
    double scrnWidth = MediaQuery.of(context).size.width;
    bool triggerRegistrationFilter = false;
    if(global.devicePlatform == "ios" && (aoFlag != null && !aoFlag)) {
      triggerRegistrationFilter = true;
    }

    double _padd = 0.0;
    double _width = scrnWidth;//100.0;

    _events.forEach((e){
      //print(e.thumbnail);
      //print("${e.eventTitle} >> ${e.eventTitle.length}");
      if(e.eventTitle.length >= 46) {
        _padd = 10.0;
        _width = 60.0;
      }

      if(!triggerRegistrationFilter || (e.uberRegister)) {
        listTiles.add(generateEventTiles(e, _padd, _width));
      }
    });

    _pastEvents.forEach((e){
      print("eventTitle: ${e.eventTitle}");
      if(e.eventTitle.length >= 46) {
        _padd = 10.0;
        _width = 60.0;
      }

      if(!triggerRegistrationFilter || (e.uberRegister)) {
        prevTiles.add(generateEventTiles(e, _padd, _width));
      }
    });
  }
  
  Widget generateEventTiles(e, _padd, _width) {
    return new InkWell(
        onTap: () {
          global.messageLogs.add("Event [${e.eventTitle}] clicked.");
          AnalyticsUtil.sendAnalyticsEvent("event_item_clicked", params: {
            "EventTitle": e.eventTitle
          });
          _handleEventTap(e);
        },
        child: new EventsListTile(
          leadingColor: e.thumbnailBg != null ? new Color(
              int.parse(e.thumbnailBg)) : Theme
              .of(context)
              .primaryColor,
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
                        style: new TextStyle(
                            color: new Color(0xff00e5ff))),
                    new Container(
                      //color: Colors.amber,
                      padding: new EdgeInsets.only(left: _padd),
                      width: _width,
                      //padding: const EdgeInsets.only(left: 20.0),
                      child: new Text(e.year.toString(),
                          style: new TextStyle(
                              color: new Color(0xff00e5ff))),
                    )
                  ],
                ),
              ],
            ),
            //child: new ListTileText(e.eventTitle)
          ),
          leading: new Container(
              height: 78.0,
              width: 140.0,
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              //child: new Image.network(e.thumbnail),
              child: (_thumbImages != null &&
                  _thumbImages.containsKey(e.thumbnail))
                  ? _thumbImages[e.thumbnail]
                  : new Container()
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
    );
  }

  void _eventsListSetup() {
    // loading indicator set
    listTiles.add(
        new Container(
          height: 120.0,
          //color: Colors.cyanAccent,
          alignment: Alignment.center,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("Loading"),
              new Container(
                  margin: const EdgeInsets.only(left: 10.0),
                  width: 20.0,
                  height: 20.0,
                  child: new CircularProgressIndicator()
              )
            ],
          ),
        )
    );

    MframePlugins.platform.then((_platform){
      if(_platform != null)
        global.devicePlatform = _platform;
    });

    eventListRunning = true;
    if(listener != null) {
      listener.cancel();
      listener = null;
    }
    listener = EventDao.eventsListener((events) {
      setState(() {
        print("set events [${events.length}]");
        _events = [];
        _events.addAll(events);
        _buildListTiles();
        eventListRunning = false;
      });
    });

    pastEventRunning = true;
    if(past_listener != null) {
      past_listener = null;
    }
    past_listener = EventDao.pastUserEventListener((events) {
      setState(() {
        print("past events LENGTH: ${events.length}");
        //_events = [];
        //_events.addAll(events);
        _pastEvents = [];
        _pastEvents.addAll(events);
        _buildListTiles();
        pastEventRunning = false;
      });
    });

    fileUtilRunning = true;
    FileUtil.downloadImagesCallback((fileName, img){
      setState((){
        Image _img = new Image.file(img);
        _thumbImages.putIfAbsent(fileName, () => _img);
        _buildListTiles();
        fileUtilRunning = false;
      });
    });
  }

  void _cleanImages() {
    List _allEvents = [];
    _allEvents.addAll(_events);
    _allEvents.addAll(_pastEvents);
    FileUtil.cleanImages(_allEvents);
  }

  @override
  void initState() {
    super.initState();

    // start performance check
    PerformanceUtil.startTrace("event_list");

    ao_listener = ConfigDao.aoFlagListener((_aoFlag){
      print("GLOBAL AO: ${_aoFlag}");
      setState(() {
        global.aoFlag = _aoFlag;
        aoFlag = _aoFlag;
        _buildListTiles();
      });
    });

    delete_listener = EventDao.removeEventListener((evt){
      print("returned");
      List<String> _evtImages = [];
      if(evt != null) {
        if(evt?.thumbnail != null)
          _evtImages.add(evt.thumbnail);
        if(evt?.hotels != null) {
          evt.hotels.forEach((hotelItm){
            if(hotelItm?.imgFilename != null) {
              _evtImages.add(hotelItm.imgFilename);
            }
          });
        }
      }
      // iterate event images
      _evtImages.forEach((img){
        FileUtil.getImage(img, isDelete: true);
      });
    });

    getCurrentUserProfile().then((_usr){
      global.currentUserProfile = _usr;
      print(_usr.email);
    });

    _eventsListSetup();

    // stop performance check
    stopTracking();

    // perform refresh events
    _eventsListTimer = new Timer.periodic(new Duration(hours: _refreshDelay), (timer) {
      print("REFRESH EVENT");
      _eventsListSetup();
    });
  }

  @override
  void dispose() {
    print("DISPOSED EVENTS WIDGET");
    super.dispose();
    listener.cancel();
    past_listener.cancel();
    if(ao_listener != null)
      ao_listener.cancel();
    if(delete_listener != null)
      delete_listener.cancel();
    if(_performanceTimer != null) {
      _performanceTimer.cancel();
    }
    if(_eventsListTimer != null) {
      _eventsListTimer.cancel();
    }
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

    if(_pastEvents?.isEmpty) {
      _children.addAll(listTiles);
    } else {
      _children.addAll(buildTabViewEvent());
    }

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
        child: _pastEvents?.isEmpty ? new ListView(
          children: _children,
        ) : new Column(
          children: _children,
        )
      ),
    );
  }
  
  List<Widget> buildTabViewEvent() {
    return <Widget>[
      new Flexible(
          child: new MFTabbedComponentDemoScaffold(
              demos: <MFComponentDemoTabData>[
                new MFComponentDemoTabData(
                  tabName: 'CURRENT',
                  description: '',
                  demoWidget: buildCurrentEvents(),
                ),
                new MFComponentDemoTabData(
                  tabName: 'PREVIOUSLY ATTENDED',
                  description: '',
                  demoWidget: buildPreviousEvents(),
                ),
              ]
          )
      )
    ];
  }

  Widget buildCurrentEvents() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listTiles,
    );
  }

  Widget buildPreviousEvents() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: prevTiles,
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