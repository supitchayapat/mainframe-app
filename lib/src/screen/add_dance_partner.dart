import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/widget/MFTabComponent.dart';
import 'package:myapp/src/util/HttpUtil.dart';
import 'package:myapp/src/dao/UserDao.dart';

class AddDancePartner extends StatefulWidget {
  @override
  _AddDancePartnerState createState() => new _AddDancePartnerState();
}

class _AddDancePartnerState extends State<AddDancePartner> {
  TextEditingController _searchCtrl = new TextEditingController();
  List users = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = "SEARCH";

    MFHttpUtil.requestFacebookFriends().then((users){
      print(users.length);
    });
    taggableFBFriendsListener((usr) {
      //print('Child added: ${usr.toJson()}');
      setState((){
        users.add(usr);
      });
    });
  }

  Widget _buildFacebookContacts() {
    List<Widget> _fbChildren = <Widget>[];
    String _letter = "";
    users.forEach((usr){
      String _curr = usr.first_name[0].toUpperCase();
      if(_letter != _curr) {
        _letter = _curr;
        _fbChildren.add(new Container(
            height: 80.0,
            margin: const EdgeInsets.only(left: 20.0),
            //color: Colors.amber,
            child: new Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  padding: new EdgeInsets.only(left: 20.0),
                  //color: Colors.redAccent,
                  child: new Text(_letter,
                    style:new TextStyle(
                        fontSize:32.0,
                        fontFamily: "Montserrat-Light",
                        color: const Color(0xff1daad2)
                    ),
                  ),
                ),
                new Container(
                  padding: new EdgeInsets.only(left: 30.0),
                  //color: Colors.cyanAccent,
                  child: new CircleAvatar(
                    backgroundImage: new NetworkImage(usr.displayPhotoUrl),
                    radius: 20.0,
                  ),
                ),
                new Container(
                  padding: new EdgeInsets.only(left: 20.0),
                  //color: Colors.purple,
                  child: new Text("${usr.first_name} ${usr.last_name}",
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontFamily: "Montserrat-Light",
                      color: const Color(0xffffffff),
                    ),
                  ),
                ),
              ],
            )
        ));
      } else {
        _fbChildren.add(new Container(
            height: 80.0,
            margin: const EdgeInsets.only(left: 20.0),
            //color: Colors.amber,
            child: new Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(padding: const EdgeInsets.only(left: 45.0)),
                new Container(
                  //color: Colors.cyanAccent,
                  padding: new EdgeInsets.only(left: 30.0),
                  child: new CircleAvatar(
                    backgroundImage: new NetworkImage(usr.displayPhotoUrl),
                    radius: 20.0,
                  ),
                ),
                new Container(
                  padding: new EdgeInsets.only(left: 20.0),
                  //color: Colors.purple,
                  child: new Text("${usr.first_name} ${usr.last_name}",
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontFamily: "Montserrat-Light",
                      color: const Color(0xffffffff),
                    ),
                  ),
                ),
              ],
            )
        ));
      }
    });

    return new Column(
      children: _fbChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    String _imgAsset = "mainframe_assets/images/add_via_email.png";

    return new Scaffold(
      appBar: new MFAppBar("ADD A DANCE PARTNER", context),
      body: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Container(
                  //color: Colors.cyanAccent,
                  height: 70.0,
                  width: _screenWidth * 0.6,
                  padding: const EdgeInsets.only(left: 15.0, top: 5.0, bottom: 10.0, right: 10.0),
                  child: new Container(
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.white),
                      borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 10.0),
                    child: new Row(
                      children: <Widget>[
                        new Icon(Icons.search),
                        new Container(
                          //color: Colors.amber,
                          width: _screenWidth * 0.4,
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.only(left: 5.0),
                          padding: const EdgeInsets.only(top: 2.0, bottom: 5.0),
                          child: new Container(
                            //onTap: () => print("SEARCH"),
                            child: new TextField(
                              decoration: new InputDecoration(
                                //labelText: "SEARCH",
                                hideDivider: true,
                              ),
                              controller: _searchCtrl,
                              onChanged: (val) {},
                            ),
                          ),
                        )
                      ],
                    ),
                  )
              ),
              new Container(
                  //color: Colors.amber,
                  width: _screenWidth * 0.4,
                  padding: const EdgeInsets.only(left: 0.0, top: 5.0, bottom: 10.0, right: 15.0),
                  child: new MainFrameButton(
                    child: new Text("ADD VIA EMAIL", style: new TextStyle(fontSize: 14.0)),
                    imgAsset: _imgAsset,
                    onPressed: () {},
                  )
              )
            ],
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          new Flexible(
            child: new MFTabbedComponentDemoScaffold(
                demos: <MFComponentDemoTabData>[
                  new MFComponentDemoTabData(
                      tabName: 'FACEBOOK',
                      description: '',
                      demoWidget: _buildFacebookContacts()
                  ),
                  new MFComponentDemoTabData(
                      tabName: 'CONTACTS',
                      description: '',
                      demoWidget: new Text("Contacts list"),
                  ),
                  new MFComponentDemoTabData(
                      tabName: 'EXISTING',
                      description: '',
                      demoWidget: new Text("Existing Partners List"),
                  ),
                ]
            ),
          )
        ],
      )
    );
  }
}