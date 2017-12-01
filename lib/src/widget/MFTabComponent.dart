import 'package:flutter/material.dart';

import 'package:myapp/src/widget/MFTab.dart';
import 'package:myapp/src/widget/MFTabs.dart';

class MFComponentDemoTabData {
  MFComponentDemoTabData({
    this.demoWidget,
    this.exampleCodeTag,
    this.description,
    this.tabName,
    this.loadMoreCallback,
    this.refreshCallback
  });

  final Widget demoWidget;
  final String exampleCodeTag;
  final String description;
  final String tabName;
  final VoidCallback loadMoreCallback;
  final VoidCallback refreshCallback;

  @override
  bool operator==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    final MFComponentDemoTabData typedOther = other;
    return typedOther.tabName == tabName && typedOther.description == description;
  }

  @override
  int get hashCode => hashValues(tabName.hashCode, description.hashCode);
}

class MFTabbedComponentDemoScaffold extends StatefulWidget {
  const MFTabbedComponentDemoScaffold({
    this.key,
    this.title,
    this.hasBackButton,
    this.demos,
  });

  final List<MFComponentDemoTabData> demos;
  final Key key;
  final String title;
  final bool hasBackButton;

  @override
  _MFTabbedComponentDemoScaffoldState createState() => new _MFTabbedComponentDemoScaffoldState();
}

class _MFTabbedComponentDemoScaffoldState extends State<MFTabbedComponentDemoScaffold> {
  List<Widget> tabs = <Widget>[];

  List<Widget> _buildTabs(double d_width) {
    double tabWidth = d_width / widget.demos.length;
    int idx = 0;
    return widget.demos.map((MFComponentDemoTabData data) {
      return new MFTab(idx++, text: data.tabName, width: tabWidth);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    tabs = _buildTabs(MediaQuery.of(context).size.width);
    double _height = MediaQuery.of(context).size.height;

    return new DefaultTabController(
      length: widget.demos.length,
      child: new Column(
        //color: Colors.amber,
        key: widget.key,
        children: <Widget>[
          new Container(
              height: 50.0,
              //color: Colors.amber,
              child: new Material(
                elevation: 5.0,
                child: new MainFrameTabBar(
                  isScrollable: false,
                  indicatorColor: new Color(0xff38e6f1),
                  indicatorWeight: 3.0,
                  tabs: tabs,
                  tabCallback: () {
                    setState((){
                      tabs = _buildTabs(MediaQuery.of(context).size.width);
                    });
                  },
                ),
              )
          ),
          new Flexible(
            child: new MainFrameTabBarView(
              children: widget.demos.map((MFComponentDemoTabData demo) {
                return new Column(
                  children: <Widget>[
                    new Padding(
                        padding: const EdgeInsets.all(10.0),
                    ),
                    //new Container(color: Colors.amber, height: 200.0)new Expanded(child: demo.demoWidget)
                    new Flexible(
                        child: new NotificationListener<OverscrollNotification>(
                            child: new ListView(
                              children: <Widget>[
                                demo.demoWidget
                              ],
                            ),
                            onNotification: (OverscrollNotification notif) {
                              //print(notif.metrics.pixels);
                              if(notif.metrics.pixels > 0.0) {
                                // reached bottom
                                // handle load more content callback
                                if(demo.loadMoreCallback != null)
                                  demo.loadMoreCallback();
                              }
                              else {
                                // reached top
                                // handle refresh callback
                                if(demo.refreshCallback != null)
                                  demo.refreshCallback();
                              }
                            },
                        )
                    )
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}