import 'package:flutter/material.dart';

class MFTabPageArrow extends StatelessWidget {
  TabController controller;
  var handleArrowButtonPress;
  Color arrowColor;
  bool isForward;
  int pagesLength;

  MFTabPageArrow({this.arrowColor, this.isForward, this.pagesLength, this.controller, this.handleArrowButtonPress});

  Widget _buildTabIndicator() {
    Widget _arrow = new IconButton(
        icon: isForward ? const Icon(Icons.chevron_right) : const Icon(Icons.chevron_left),
        color: arrowColor,
        //onPressed: Function.apply(handleArrowButtonPress, [1]),
        onPressed: handleArrowButtonPress,
        tooltip: isForward ? 'Page forward' : 'Page back'
    );
    Widget _container = new Container(height: 40.0, width: 48.0);
    Widget _retVal = _arrow;

    if (!controller.indexIsChanging) {
      if(!isForward && (pagesLength <= 1 || controller.index == 0)) {
        _retVal = _container;
      }
      else if(isForward && (pagesLength <= 1 || controller.index == (pagesLength - 1))) {
        _retVal = _container;
      }
    }

    return _retVal;
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
            child: _buildTabIndicator(),
          );
        }
    );
  }
}