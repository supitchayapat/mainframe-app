import 'package:flutter/material.dart';
import 'package:myapp/src/model/User.dart';

const String _kAsset0 = 'mainframe_assets/profile/profilePhoto.jpg';
const String _kAsset1 = 'mainframe_assets/profile/displayPhoto.jpg';
const String _kAsset2 = 'mainframe_assets/profile/displayPhoto.jpg';
//const String _kGalleryAssetsPackage = 'flutter_gallery_assets';

class MainFrameDrawer extends StatefulWidget {
  static User currentUser;
  GlobalKey<ScaffoldState> scaffoldKey;

  MainFrameDrawer(this.scaffoldKey);

  @override
  _MainFrameDrawerState createState() => new _MainFrameDrawerState(this.scaffoldKey, currentUser);
}

class _MainFrameDrawerState extends State<MainFrameDrawer> {

  GlobalKey<ScaffoldState> _scaffoldKey;
  bool _showDrawerContents = true;
  AnimationController _controller;
  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;
  static const List<String> _drawerContents = const <String>[
    'A', 'B', 'C', 'D', 'E',
  ];
  User usr;

  _MainFrameDrawerState(this._scaffoldKey,this.usr);

  void _showNotImplementedMessage() {
    Navigator.of(context).pop(); // Dismiss the drawer.
    _scaffoldKey.currentState.showSnackBar(const SnackBar(
        content: const Text("The drawer's items don't do anything")
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(usr.first_name + ' ' +usr.last_name),
            accountEmail: new Text(usr.email),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: const AssetImage(
                _kAsset0
              )
            ),
            /*onDetailsPressed: () {
              _showDrawerContents = !_showDrawerContents;
              if (_showDrawerContents)
                _controller.reverse();
              else
                _controller.forward();
            },*/
          ),
          /*new ClipRect(
                child: new Stack(
                  children: <Widget>[
                    // The initial contents of the drawer.
                    new FadeTransition(
                      opacity: _drawerContentsOpacity,
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _drawerContents.map((String id) {
                          return new ListTile(
                            leading: new CircleAvatar(child: new Text(id)),
                            title: new Text('Drawer item $id'),
                            onTap: _showNotImplementedMessage,
                          );
                        }).toList(),
                      ),
                    ),
                    // The drawer's "details" view.
                    new SlideTransition(
                      position: _drawerDetailsPosition,
                      child: new FadeTransition(
                        opacity: new ReverseAnimation(_drawerContentsOpacity),
                        child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            new ListTile(
                              leading: const Icon(Icons.add),
                              title: const Text('Add account'),
                              onTap: _showNotImplementedMessage,
                            ),
                            new ListTile(
                              leading: const Icon(Icons.settings),
                              title: const Text('Manage accounts'),
                              onTap: _showNotImplementedMessage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),*/
        ],
      ),
    );
  }
}