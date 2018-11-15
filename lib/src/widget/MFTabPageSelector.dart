import 'package:flutter/material.dart';

class MFTabPageSelector extends StatelessWidget {
  TabController controller;
  List<String> tabPages;

  MFTabPageSelector({this.controller, this.tabPages});

  Widget _buildTabIndicator() {
    String _tabName = tabPages[controller.previousIndex];
    if (!controller.indexIsChanging) {
      //print("tabIdx: $tabIndex");
      //print("idx: ${controller.index} prev: ${controller.previousIndex}");
      _tabName = tabPages[controller.index];
      //print("Tab Name: $_tabName");
    }

    return new Center(
        child: new Text(_tabName,
          style: new TextStyle(fontSize: 18.0, fontFamily: "Montserrat-Light")//, fontWeight: FontWeight.bold),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final TabController tabController = controller ?? DefaultTabController.of(context);
    assert(() {
      if (tabController == null) {
        throw new FlutterError(
            'No TabController for $runtimeType.\n'
                'When creating a $runtimeType, you must either provide an explicit TabController '
                'using the "controller" property, or you must ensure that there is a '
                'DefaultTabController above the $runtimeType.\n'
                'In this case, there was neither an explicit controller nor a default controller.'
        );
      }
      return true;
    }());
    final Animation<double> animation = new CurvedAnimation(
      parent: tabController.animation,
      curve: Curves.fastOutSlowIn,
    );
    return new AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return new Semantics(
            label: 'Page ${tabController.index + 1} of ${tabController.length}',
            /*child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: new List<Widget>.generate(tabController.length, (int tabIndex) {
                return _buildTabIndicator(tabIndex, tabController);
              }).toList(),
            ),*/
            child: _buildTabIndicator(),
          );
        }
    );
  }
}