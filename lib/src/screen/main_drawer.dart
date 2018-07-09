import 'package:flutter/material.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/util/AnalyticsUtil.dart';

/*
  Author: Art

  [MainFrameDrawer] is a Drawer widget that contains Side Nav menu for the Application
 */

class MainFrameDrawer extends StatefulWidget {
  static User currentUser;
  GlobalKey<ScaffoldState> scaffoldKey;
  MainFrameDrawer(this.scaffoldKey);

  @override
  _MainFrameDrawerState createState() => new _MainFrameDrawerState(this.scaffoldKey, currentUser);
}

/*
  [_MenuContent] class refers to the menu contents of the [MainFrameDrawer]
  Side Nav menu.
 */
class _MenuContent {
  String menuLabel;
  dynamic menuNavUri;
  IconData menuIcon;
  bool isParent;
  bool isLastMenu;
  String iconImage;

  _MenuContent(this.menuLabel, this.menuNavUri, this.iconImage, this.isParent, this.isLastMenu, {this.menuIcon});
}

class _MainFrameDrawerState extends State<MainFrameDrawer> with TickerProviderStateMixin {

  final List<_MenuContent> _drawerContents = <_MenuContent>[];

  GlobalKey<ScaffoldState> _scaffoldKey;
  bool _showDrawerContents = true;
  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;
  User usr;

  _MainFrameDrawerState(this._scaffoldKey,this.usr);

  bool _logoutUser() {
    logoutUser();
    return true;
  }

  bool _showTips() {
    setState((){
      global.hasTips = !global.hasTips;
    });
    return false;
  }

  void _showNotImplementedMessage() {
    _scaffoldKey.currentState.showSnackBar(const SnackBar(
        content: const Text("This feature is not yet available.")
    ));
  }

  /*
    Method implementation when the Side Nav menu is pressed.
   */
  void _MFMenuPressed(_MenuContent content) {
    // crashlytics logging
    global.messageLogs.add("SideNav menu button pressed [${content.menuLabel}]");
    AnalyticsUtil.sendAnalyticsEvent("sidenav_menu_press", params: {
      'screen': 'main_drawer'
    });

    Navigator.of(context).pop(); // Dismiss the drawer.

    if(content.menuNavUri == null ||
        (content.menuNavUri is String && content.menuNavUri.isEmpty)) {
      if(!content.isParent)
        _showNotImplementedMessage();
    }
    else {
      if(content.menuNavUri is String) {
        Navigator.pushNamed(context, content.menuNavUri);
      } else {
        bool popNav = content.menuNavUri();
        if(popNav) {
          Navigator.of(context).pushReplacementNamed("/loginscreen");
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    /*
      Below is a list of Menu and their corresponding Navigation link.
      each _MenuContent can be either a Parent menu or a Child menu
     */
    _drawerContents.addAll([
      new _MenuContent("MENU", "", null, true, false),
      //new _MenuContent("Find Service Center", "", "mainframe_assets/icons/noun_1049935_cc@2x.png", false, false),
      //new _MenuContent("Map View", "", "mainframe_assets/icons/noun_939113_cc@2x.png", false, false),
      //new _MenuContent("Messages", "", "mainframe_assets/icons/noun_1042992_cc@2x.png", false, false),
      //new _MenuContent("Industry News", "", "mainframe_assets/icons/noun_1129072_cc@2x.png", false, false),
      //new _MenuContent("ACCOUNT", "", null, true, false),
      //new _MenuContent("Settings", "", "mainframe_assets/icons/noun_1098180_cc@2x.png", false, false),
      new _MenuContent("Edit Profile", "/profilesetup-1", "", false, false, menuIcon: Icons.person),
      new _MenuContent("Logout", _logoutUser, "mainframe_assets/icons/noun_1037967_cc@2x.png", false, false),
      //new _MenuContent("TECH SUPPORT", "", null, true, false),
      new _MenuContent("Show Tips "+(global.hasTips ? "[ON]" : "[OFF]"), _showTips, "", false, false, menuIcon: Icons.lightbulb_outline),
      new _MenuContent("About", "/contactUs", "", false, true, menuIcon: Icons.info_outline),
    ]);

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> _generateRowChildren(_MenuContent content) {
      List<Widget> children = <Widget>[];
      Widget _icon;
      if(content.iconImage != null && content.iconImage.isNotEmpty) {
        _icon = new ImageIcon(new ExactAssetImage(content.iconImage), color: Colors.white, size: 16.0,);
      } else {
        _icon = new Icon(content.menuIcon, size: 20.0);
      }
      if(!content.isParent) {
        //children.add(new Icon(content.menuIcon, color: Colors.white));
        children.add(
            new Container(
                child: new Row(
                  children: <Widget>[
                    //new ImageIcon(new ExactAssetImage(content.iconImage), color: Colors.white, size: 16.0,),
                    _icon,
                    new Padding(padding: const EdgeInsets.only(right: 8.0)),
                    new Text(content.menuLabel)
                  ],
                ),
                padding: const EdgeInsets.only(top: 5.0)
            )
        );
        //children.add(new ImageIcon(new ExactAssetImage(content.iconImage), color: Colors.white, size: 16.0,));
        //children.add(new Padding(padding: const EdgeInsets.only(right: 8.0)));
        //children.add(new Text(content.menuLabel));
      } else {
        children.add(
            new Container(
                child: new Text(
                    content.menuLabel,
                    style: new TextStyle(fontWeight: FontWeight.bold)
                ),
                padding: const EdgeInsets.only(top: 5.0)
            )
        );
      }
      return children;
    }

    return new Drawer(
      child: new ListView(
        children: <Widget>[
          //new Padding(padding: new EdgeInsets.all(10.0)),
          new ClipRect(
            child: new Stack(
              children: <Widget>[
                // The initial contents of the drawer.
                new FadeTransition(
                  opacity: _drawerContentsOpacity,
                  child: new Container(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _drawerContents.map<Widget>((_MenuContent content) {
                        return new _MFListTile(
                          //leading: new CircleAvatar(child: new Text(id)),
                          leading: new Container(
                              //color: Colors.amber,
                              child: new Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Container(
                                    alignment: Alignment.topRight,
                                    padding: new EdgeInsets.only(top: 10.0),
                                    //color: Colors.blue,
                                    child: new Column(
                                      children: <Widget>[
                                        new Icon(Icons.brightness_1, size: 8.0, color: content.isParent ? Colors.red : Colors.white),
                                        new DefaultTextStyle(
                                            style: new TextStyle(fontSize: 26.0, fontFamily: "Monserrat-Light", fontWeight: FontWeight.w200),
                                            child: new Text(content.isLastMenu ? "" : "|")
                                        )
                                      ],
                                    ),
                                  ),
                                  new Container(
                                    alignment: Alignment.topLeft,
                                    margin: new EdgeInsets.only(left: 5.0, bottom: 30.0),
                                    padding: new EdgeInsets.only(bottom: 5.0),
                                    //color: Colors.red,
                                    child: new DefaultTextStyle(
                                        style: new TextStyle(fontSize: 25.0, fontFamily: "Monserrat-Light", fontWeight: FontWeight.w200),
                                        child: new Text("—")
                                    ),
                                  )
                                ],
                              )
                          ),
                          //trailing: new Text("traling"),
                          //subtitle: new Text("sub"),
                          title: new Container(
                            //color: Colors.orange,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new DefaultTextStyle(
                                      style: new TextStyle(fontSize: 16.0, fontFamily: "Montserrat-Light",color: content.isParent ? new Color(0xfff4101d) : Colors.white
                                    ),
                                    child: new Row(
                                      children: _generateRowChildren(content),
                                    )
                                )
                              ],
                            ),
                          ),
                          onTap: () => _MFMenuPressed(content),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
  [_MFListTile] extends class [ListTile]
  The class is tailored for the Application's Nav menu
 */
class _MFListTile extends ListTile {
  _MFListTile({Widget leading, Widget trailing, Widget title, Widget subtitle, GestureTapCallback onTap})
  : super(leading: leading, trailing: trailing, title: title, subtitle: subtitle, onTap: onTap);

  bool _denseLayout(ListTileTheme tileTheme) {
    return dense != null ? dense : (tileTheme?.dense ?? false);
  }

  Color _iconColor(ThemeData theme, ListTileTheme tileTheme) {
    if (!enabled)
      return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme?.iconColor != null)
      return tileTheme.iconColor;

    switch (theme.brightness) {
      case Brightness.light:
        return selected ? theme.primaryColor : Colors.black45;
      case Brightness.dark:
        return selected ? theme.accentColor : null; // null - use current icon theme color
    }
    assert(theme.brightness != null);
    return null;
  }

  Color _textColor(ThemeData theme, ListTileTheme tileTheme, Color defaultColor) {
    if (!enabled)
      return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme?.textColor != null)
      return tileTheme.textColor;

    if (selected) {
      switch (theme.brightness) {
        case Brightness.light:
          return theme.primaryColor;
        case Brightness.dark:
          return theme.accentColor;
      }
    }
    return defaultColor;
  }

  TextStyle _subtitleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    final TextStyle style = theme.textTheme.body1;
    final Color color = _textColor(theme, tileTheme, theme.textTheme.caption.color);
    return _denseLayout(tileTheme)
        ? style.copyWith(color: color, fontSize: 12.0)
        : style.copyWith(color: color);
  }

  TextStyle _titleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    final TextStyle style = tileTheme?.style == ListTileStyle.drawer
        ? theme.textTheme.body2
        : theme.textTheme.subhead;
    final Color color = _textColor(theme, tileTheme, style.color);
    return _denseLayout(tileTheme)
        ? style.copyWith(fontSize: 13.0, color: color)
        : style.copyWith(color: color);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData theme = Theme.of(context);
    final ListTileTheme tileTheme = ListTileTheme.of(context);

    final bool isTwoLine = !isThreeLine && subtitle != null;
    final bool isOneLine = !isThreeLine && !isTwoLine;
    double tileHeight;
    if (isOneLine)
      tileHeight = _denseLayout(tileTheme) ? 48.0 : 56.0;
    else if (isTwoLine)
      tileHeight = _denseLayout(tileTheme) ? 60.0 : 72.0;
    else
      tileHeight = _denseLayout(tileTheme) ? 76.0 : 88.0;
    // Overall, the list tile is a Row() with these children.
    final List<Widget> children = <Widget>[];

    IconThemeData iconThemeData;
    if (leading != null || trailing != null)
      iconThemeData = new IconThemeData(color: _iconColor(theme, tileTheme));

    if (leading != null) {
      children.add(IconTheme.merge(
        data: iconThemeData,
        child: new Container(
          margin: const EdgeInsetsDirectional.only(end: 5.0),
          width: 40.0,
          alignment: AlignmentDirectional.centerStart,
          child: leading,
        ),
      ));
    }

    final Widget primaryLine = new AnimatedDefaultTextStyle(
        style: _titleTextStyle(theme, tileTheme),
        duration: kThemeChangeDuration,
        child: title ?? new Container()
    );
    Widget center = primaryLine;
    if (subtitle != null && (isTwoLine || isThreeLine)) {
      center = new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          primaryLine,
          new AnimatedDefaultTextStyle(
            style: _subtitleTextStyle(theme, tileTheme),
            duration: kThemeChangeDuration,
            child: subtitle,
          ),
        ],
      );
    }
    children.add(new Expanded(
      child: center,
    ));

    if (trailing != null) {
      children.add(IconTheme.merge(
        data: iconThemeData,
        child: new Container(
          margin: const EdgeInsetsDirectional.only(start: 16.0),
          alignment: AlignmentDirectional.centerEnd,
          child: trailing,
        ),
      ));
    }

    return new InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        child: new Container(
          height: 48.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new Row(children: children),
        )
    );
  }
}