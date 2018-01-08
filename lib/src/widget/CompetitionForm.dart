import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

const Duration _kBaseSettleDuration = const Duration(milliseconds: 246);
const double _kWidth = 304.0;

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override double get minExtent => minHeight;
  @override double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    Widget box = new SizedBox.expand(
      child: child,
    );
    return box;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight
        || minHeight != oldDelegate.minHeight
        || child != oldDelegate.child;
  }

  @override
  String toString() => '_SliverAppBarDelegate';
}

class CompetitionForm extends StatefulWidget {
  Widget minimizedLeftPanel;
  Widget maximizedLeftPanel;
  List<Widget> rightPanelTabs;
  double rPanelWidth;

  CompetitionForm({
    @required this.maximizedLeftPanel,
    @required this.minimizedLeftPanel,
    this.rightPanelTabs,
    @required this.rPanelWidth
  });

  @override
  _CompetitionFormState createState() => new _CompetitionFormState();
}

class _CompetitionFormState extends State<CompetitionForm> {
  ScrollController _scrollController = new ScrollController();
  final GlobalKey _drawerKey = new GlobalKey();
  Widget leftPanel;
  Widget rightPanel;
  bool isMaximizedLeft = true;
  bool isBuildRPanel = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_panelResizedListener);
    leftPanel = widget.maximizedLeftPanel;
    rightPanel = new Container(color: new Color(0xff113E69));
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _panelResizedListener() {
    setState(() {
      if(!_scrollController.position.atEdge) {
        if(_scrollController.position.pixels > 50.0) {
          leftPanel = _buildMinimizedLPanel();
          isMaximizedLeft = false;
        } else {
          leftPanel = _buildMaximizedLPanel();
          isMaximizedLeft = true;
        }
      }
      else {
        if(_scrollController.position.pixels < 50.0) {
          leftPanel = _buildMaximizedLPanel();
          isMaximizedLeft = true;
        }
        else {
          leftPanel = _buildMinimizedLPanel();
          isMaximizedLeft = false;
        }
      }

      if(_width <= 200.0) {
        rightPanel = _buildRightPanel();
        isBuildRPanel = true;
      }
      else {
        rightPanel = new Container(color: new Color(0xff113E69));
        isBuildRPanel = false;
      }
    });
  }

  Widget _buildMaximizedLPanel() {
    return widget.maximizedLeftPanel;
  }

  Widget _buildMinimizedLPanel() {
    return widget.minimizedLeftPanel;
  }

  Widget _buildRightPanel() {
    List<Widget> children = <Widget>[];
    // check if orientation is not landscape
    if(MediaQuery.of(context).orientation != Orientation.landscape) {
      String scapeText = "Please change orientation to landscape";
      return new Container(color: new Color(0xff113E69), child: new Text(scapeText));
    }

    if(widget.rightPanelTabs != null) {
      children.addAll(widget.rightPanelTabs.map((widget) {
        return new Container(
          child: new Center(
              child: widget
          ),
        );
      }).toList());
    }
    else {
      children.add(new Container());
    }
    return new DefaultTabController(
        length: widget.rightPanelTabs != null ? widget.rightPanelTabs.length : 0,
        child: new Container(
          //color: new Color(0xff113E69),
          child: new TabBarView(
              children: children,
          ),
        )
    );
  }

  double get _width {
    final RenderBox box = _drawerKey.currentContext?.findRenderObject();
    if (box != null)
      return box.size.width;
    return _kWidth; // drawer not being shown currently
  }

  Widget _buildBody(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    double rPanelWidth = mediaQueryData.size.width * 0.57; //205.0;
    //print(mediaQueryData.orientation);
    if(mediaQueryData.orientation == Orientation.landscape) {
      rPanelWidth = (widget.rPanelWidth != null && widget.rPanelWidth > 0) ? widget.rPanelWidth : rPanelWidth;
    }
    //print("${mediaQueryData.size.width} - 250.0");
    if((rPanelWidth + 300) < mediaQueryData.size.width) {
      rPanelWidth += mediaQueryData.size.width - (rPanelWidth + 300);
      rPanelWidth += 185;
    }

    if(isMaximizedLeft) {
      leftPanel = _buildMaximizedLPanel();
    }
    if(isBuildRPanel) {
      rightPanel = _buildRightPanel();
    }

    //print("from inside form: ${rPanelWidth}");

    return new SizedBox.expand(
      child: new NotificationListener<ScrollEndNotification>(
          onNotification: (endNotification) {},
          child: new Stack(
            children: <Widget>[
              // Persistent left Panel
              new CustomScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                slivers: <Widget>[
                  new SliverPersistentHeader(
                      pinned: true,
                      delegate: new _SliverAppBarDelegate(
                          minHeight: 115.0, // must depend on screen width
                          maxHeight: 300.0, // must depend on screen width
                          child: new Container(
                            //color: Colors.cyanAccent,
                            key: _drawerKey,
                            //color: const Color(0xff1a7fa7),
                            child: leftPanel,
                          )
                      )
                  ),
                  // Right Panel
                  new SliverToBoxAdapter(
                    child: new SizedBox(
                      width: rPanelWidth, // must adjust depending on screen width
                      child: rightPanel
                    ),
                  )
                ],
              )
            ],
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Builder(
      builder: _buildBody,
    );
  }
}