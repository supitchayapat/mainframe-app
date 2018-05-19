// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'example_code_parser.dart';
import 'syntax_highlighter.dart';
import 'package:myapp/src/widget/MFTab.dart';
import 'package:myapp/src/widget/MFTabs.dart';

class ComponentDemoTabData {
  ComponentDemoTabData({
    this.demoWidget,
    this.exampleCodeTag,
    this.description,
    this.tabName
  });

  final Widget demoWidget;
  final String exampleCodeTag;
  final String description;
  final String tabName;

  @override
  bool operator==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    final ComponentDemoTabData typedOther = other;
    return typedOther.tabName == tabName && typedOther.description == description;
  }

  @override
  int get hashCode => hashValues(tabName.hashCode, description.hashCode);
}

class TabbedComponentDemoScaffold extends StatefulWidget {
  const TabbedComponentDemoScaffold({
    this.key,
    this.title,
    this.hasBackButton,
    this.demos
  });

  final List<ComponentDemoTabData> demos;
  final Key key;
  final String title;
  final bool hasBackButton;

  @override
  _TabbedComponentDemoScaffoldState createState() => new _TabbedComponentDemoScaffoldState();
}

class _TabbedComponentDemoScaffoldState extends State<TabbedComponentDemoScaffold> {
  List<Widget> tabs = <Widget>[];

  List<Widget> _buildTabs(double d_width) {
    double tabWidth = d_width / widget.demos.length;
    int idx = 0;
    return widget.demos.map<Widget>((ComponentDemoTabData data) {
      return new MFTab(idx++, text: data.tabName, width: tabWidth);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    tabs = _buildTabs(MediaQuery.of(context).size.width);

    return new DefaultTabController(
      length: widget.demos.length,
      child: new Scaffold(
        key: widget.key,
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios),
              color: Colors.white,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () {
                Navigator.of(context).maybePop();
              }
          ),
          title: new Text(widget.title),
          bottom: new MainFrameTabBar(
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
        ),
        body: new MainFrameTabBarView(
          children: widget.demos.map<Widget>((ComponentDemoTabData demo) {
            return new Column(
              children: <Widget>[
                new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: new Text(demo.description,
                        style: Theme.of(context).textTheme.subhead
                    )
                ),
                new Expanded(child: demo.demoWidget)
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class FullScreenCodeDialog extends StatefulWidget {
  const FullScreenCodeDialog({ this.exampleCodeTag });

  final String exampleCodeTag;

  @override
  FullScreenCodeDialogState createState() => new FullScreenCodeDialogState();
}

class FullScreenCodeDialogState extends State<FullScreenCodeDialog> {

  String _exampleCode;

  @override
  void didChangeDependencies() {
    getExampleCode(widget.exampleCodeTag, DefaultAssetBundle.of(context)).then<Null>((String code) {
      if (mounted) {
        setState(() {
          _exampleCode = code;
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final SyntaxHighlighterStyle style = Theme.of(context).brightness == Brightness.dark
        ? SyntaxHighlighterStyle.darkThemeStyle()
        : SyntaxHighlighterStyle.lightThemeStyle();

    Widget body;
    if (_exampleCode == null) {
      body = const Center(
          child: const CircularProgressIndicator()
      );
    } else {
      body = new SingleChildScrollView(
          child: new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new RichText(
                  text: new TextSpan(
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10.0),
                      children: <TextSpan>[
                        new DartSyntaxHighlighter(style).format(_exampleCode)
                      ]
                  )
              )
          )
      );
    }

    return new Scaffold(
        appBar: new AppBar(
            leading: new IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () { Navigator.pop(context); }
            ),
            title: const Text('Example code')
        ),
        body: body
    );
  }
}