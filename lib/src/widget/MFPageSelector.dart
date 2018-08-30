import 'package:flutter/material.dart';
import 'MFTabPageSelector.dart';
import 'MFTabPageArrow.dart';

class PageSelectData {
  PageSelectData({
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
    final PageSelectData typedOther = other;
    return typedOther.tabName == tabName && typedOther.description == description;
  }

  @override
  int get hashCode => hashValues(tabName.hashCode, description.hashCode);
}

class _PageSelector extends StatefulWidget {

  List<PageSelectData> pageWidgets;

  _PageSelector({this.pageWidgets});

  @override
  _PageSelectorState createState() => new _PageSelectorState();
}

class _PageSelectorState extends State<_PageSelector> {

  void _handleArrowButtonPress(int delta) {
    final TabController controller = DefaultTabController.of(context);
    setState((){
      if (!controller.indexIsChanging)
        controller.animateTo((controller.index + delta).clamp(0, widget.pageWidgets.length - 1));
      //print("idx: ${controller.index} prev: ${controller.previousIndex}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    final Color color = Theme.of(context).accentColor;
    return new Column(
      children: <Widget>[
        new Container(
            //color: Colors.amber,
            child: new Row(
                children: <Widget>[
                  /*(widget.pageWidgets.length > 1 && controller.index > 0) ? new IconButton(
                      icon: const Icon(Icons.chevron_left),
                      color: color,
                      onPressed: () { _handleArrowButtonPress(context, -1); },
                      tooltip: 'Page back'
                  ) : new Container(height: 40.0, width: 48.0),*/
                  new MFTabPageArrow(
                    controller: controller,
                    arrowColor: color,
                    handleArrowButtonPress: () {
                      _handleArrowButtonPress(-1);
                    },
                    isForward: false,
                    pagesLength: widget.pageWidgets.length,
                  ),
                  /*new Center(
                      child: new Text(widget.pageWidgets[controller.index].tabName,
                        style: new TextStyle(fontSize: 18.0, fontFamily: "Montserrat-Light", fontWeight: FontWeight.bold),
                      )
                  ),*/
                  new MFTabPageSelector(
                      controller: controller,
                      tabPages: widget.pageWidgets.map((pSelData){
                        return pSelData.tabName;
                      }).toList()),
                  /*(widget.pageWidgets.length > 1 && controller.index < (widget.pageWidgets.length - 1)) ? new IconButton(
                      icon: const Icon(Icons.chevron_right),
                      color: color,
                      onPressed: () { _handleArrowButtonPress(1); },
                      tooltip: 'Page forward'
                  ) : new Container(height: 40.0, width: 48.0)*/
                  new MFTabPageArrow(
                    controller: controller,
                    arrowColor: color,
                    handleArrowButtonPress: (){
                      _handleArrowButtonPress(1);
                    },
                    isForward: true,
                    pagesLength: widget.pageWidgets.length,
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween
            )
        ),
        new Expanded(
          child: new TabBarView(
              children: widget.pageWidgets.map<Widget>((_w){
                return new ListView(
                  children: <Widget>[
                    _w.demoWidget
                  ],
                );
              }).toList()
          ),
        ),
      ],
    );
  }
}

class MFPageSelector extends StatefulWidget {

  List<PageSelectData> pageWidgets;

  MFPageSelector({this.pageWidgets});

  @override
  _MFPageSelectorState createState() => new _MFPageSelectorState();
}

class _MFPageSelectorState extends State<MFPageSelector> {

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: widget.pageWidgets.length,
      child: new _PageSelector(pageWidgets: widget.pageWidgets),
    );
  }
}