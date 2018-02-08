import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/widget/MFTabComponent.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:validator/validator.dart';
import 'package:mframe_plugins/mframe_plugins.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/util/HttpUtil.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/screen/participant_list.dart' as participant;
import 'package:myapp/src/screen/couple_management.dart' as couple;

class AddDancePartner extends StatefulWidget {
  @override
  _AddDancePartnerState createState() => new _AddDancePartnerState();
}

class _AddDancePartnerState extends State<AddDancePartner> {
  TextEditingController _searchCtrl = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List users = [];
  List existingUsers = [];
  List contacts = [];
  int _page = 10;

  @override
  void initState() {
    super.initState();
    //setState((){
      _searchCtrl.text = "SEARCH";
    //});
    MframePlugins.phoneContacts().then((val){
      setState(() {
        contacts = val;
      });
    });

    global.taggableFriends.then((usrs){
      setState((){
        if(usrs != null && !usrs.isEmpty) {
          int _ctr = 1;
          for(var usr in usrs) {
            if(_ctr <= 10) {
              users.add(usr);
            }
            else {
              break;
            }
            _ctr++;
          }
        }
      });
    });

    getUserExistingParticipants().then((usersData){
      setState((){
        existingUsers.addAll(usersData);
      });
    });
  }

  void _inviteWithEmail() {
    // will send email immediately right after finish dance partner forms
    /*var _ans = showMainFrameDialogWithCancel(
        context, "Invite via Email",
        "Do you want to send email to ${_searchCtrl.text} and add as a Dance Partner?")
        .then((_ans){
      if(_ans == "OK") {
        // send email
        print("Invite and add as partner on email.");
        MFHttpUtil.sendMailInvite().then((val) {
          global.setDancePartner = _searchCtrl.text;
          Navigator.of(context).pushNamed("/profilesetup-1");
        });
      } else {
        global.setDancePartner = _searchCtrl.text;
        Navigator.of(context).pushNamed("/profilesetup-1");
      }
    });*/
    global.setDancePartner = _searchCtrl.text;
    Navigator.of(context).pushNamed("/profilesetup-1");
  }

  void _handleAddViaEmail() {
    FormState form = _formKey.currentState;
    if(!form.validate()) {
      showInSnackBar(_scaffoldKey, 'Please fix the errors in red before submitting.');
    } else {
      // check if email is an existing app user
      userExistsByEmail(_searchCtrl.text).then((usr){
        if(usr != null) {
          // user exists, do you want to save User as Dance partner?
          var _ans = showMainFrameDialogWithCancel(
              context, "Registered User",
              "${usr.first_name} ${usr.last_name} with email ${_searchCtrl.text} is already a registered user. Is this the dance partner you want to add?")
              .then((_ans){
            if(_ans == "OK") {
              // save dance partner
              global.dancePartner = usr;
              saveUserExistingParticipants(usr);
            }
            else {
              _inviteWithEmail();
            }
          });
        } else {
          _inviteWithEmail();
        }
      });
    }
  }

  String _validateEmail(String value) {
    if(value.isEmpty) {
      return "Email Field Required";
    }
    if(!isEmail(value)){
      return "Invalid Email";
    }
    return null;
  }

  void _handleTapFBFriend(usr) {
    var _ans = showMainFrameDialogWithCancel(
        context, "Invite Friend",
        "Do you want to send facebook message to ${usr.first_name} ${usr.last_name} as a Participant?")
        .then((_ans){
          if(_ans == "OK") {
            showFacebookAppShareDialog();
          }

          global.setDancePartner = "${usr.first_name}|${usr.last_name}";
          Navigator.of(context).pushNamed("/profilesetup-1");
    });
  }

  void _handleTapExisting(usr) {
    // TODO: will implement saving of entry form
    if(participant.participantType == "solo") {
      MainFrameLoadingIndicator.showLoading(context);
      // save participant
      saveUserSoloParticipants(usr).then((_val){
        MainFrameLoadingIndicator.hideLoading(context);
        Navigator.of(context).popUntil(ModalRoute.withName("/participants"));
      });
    }
    else if(participant.participantType == "couple") {
      // navigate couple management screen
      if(couple.couple1 is String && couple.couple1 == "_assignCoupleParticipant") {
        setState((){
          couple.couple1 = usr;
        });
      }

      if(couple.couple2 is String && couple.couple2 == "_assignCoupleParticipant") {
        setState((){
          couple.couple2 = usr;
        });
      }
      Navigator.of(context).popUntil(ModalRoute.withName("/coupleManagement"));
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName("/addPartner"));
    }
  }

  _loadMoreFBContacts() {
    //print("load more");
    global.taggableFriends.then((usrs){
      if(usrs != null && !usrs.isEmpty) {
        int _ctr = 1;
        while(_page < usrs.length) {
          if(_ctr <= 10) {
            setState((){
              users.add(usrs[_page]);
            });
          }
          else {
            break;
          }
          _ctr++;
          _page++;
        }
      }
    });
  }

  Widget _buildPhoneContacts() {
    double _screenWidth = MediaQuery.of(context).size.width;
    List<Widget> _children = <Widget>[];
    String _letter = "";

    contacts.sort((a, b) => (a.contactName.toUpperCase()).compareTo(b.contactName.toUpperCase()));

    contacts.forEach((con){
      String _curr = con.contactName[0].toUpperCase();
      ImageProvider _profilePhoto = new AssetImage("mainframe_assets/images/user-avatar.png");

      if(_letter != _curr) {
        _letter = _curr;
        _children.add(new InkWell(
          onTap: () {
            global.setDancePartner = con.contactName;
            Navigator.of(context).pushNamed("/profilesetup-1");
          },
          child: new Container(
              height: 80.0,
              margin: const EdgeInsets.only(left: 20.0),
              //color: Colors.amber,
              child: new Row(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    padding: new EdgeInsets.only(left: 20.0),
                    //color: Colors.amber,
                    child: new Container(
                      alignment: Alignment.center,
                      width: 25.0,
                      //color: Colors.cyanAccent,
                      child: new Text(_letter,
                        style:new TextStyle(
                            fontSize:32.0,
                            fontFamily: "Montserrat-Light",
                            color: const Color(0xff1daad2)
                        ),
                      ),
                    ),
                  ),
                  new Container(
                    padding: new EdgeInsets.only(left: 30.0),
                    //color: Colors.cyanAccent,
                    child: new CircleAvatar(
                      backgroundImage: _profilePhoto,
                      radius: 20.0,
                    ),
                  ),
                  new Container(
                    padding: new EdgeInsets.only(left: 20.0),
                    //color: Colors.cyanAccent,
                    width: _screenWidth * 0.6,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          //padding: const EdgeInsets.only(left: 7.0),
                          alignment: Alignment.centerLeft,
                          child: new Text(con.contactName,
                            style: new TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Montserrat-Light",
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),
                        new Container(
                          alignment: Alignment.centerLeft,
                          child: new Text(con.contactPhone,
                            style: new TextStyle(
                              fontSize: 14.0,
                              fontFamily: "Montserrat-Light",
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                ],
              )
          ),
        ));
      } else {
        _children.add(new InkWell(
          onTap: () {
            global.setDancePartner = con.contactName;
            Navigator.of(context).pushNamed("/profilesetup-1");
          },
          child: new Container(
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
                      backgroundImage: _profilePhoto,
                      radius: 20.0,
                    ),
                  ),
                  new Container(
                      padding: new EdgeInsets.only(left: 20.0),
                      //color: Colors.cyanAccent,
                      width: _screenWidth * 0.6,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            //padding: const EdgeInsets.only(left: 7.0),
                            alignment: Alignment.centerLeft,
                            child: new Text(con.contactName,
                              style: new TextStyle(
                                fontSize: 16.0,
                                fontFamily: "Montserrat-Light",
                                color: const Color(0xffffffff),
                              ),
                            ),
                          ),
                          new Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(con.contactPhone,
                              style: new TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat-Light",
                                color: const Color(0xffffffff),
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                ],
              )
          ),
        ));
      }
    });

    return new Column(
      children: _children,
    );
  }

  Widget _buildExistingContacts() {
    return new Column(
      children: _buildContactLayout(existingUsers, true),
    );
  }

  Widget _buildFacebookContacts() {
    return new Column(
      children: _buildContactLayout(users, false),
    );
  }

  List<Widget> _buildContactLayout(contactUsers, isExisting) {
    double _screenWidth = MediaQuery.of(context).size.width;
    List<Widget> _children = <Widget>[];
    String _letter = "";

    contactUsers.forEach((usr){
      String _curr = usr.first_name[0].toUpperCase();
      String _displayPhoto = usr.displayPhotoUrl;
      ImageProvider _profilePhoto;

      if(_displayPhoto != null && !_displayPhoto.isEmpty) {
        _profilePhoto = new NetworkImage(usr.displayPhotoUrl);
      } else {
        _profilePhoto = new AssetImage("mainframe_assets/images/user-avatar.png");
      }

      if(_letter != _curr) {
        _letter = _curr;
        _children.add(new InkWell(
          onTap: () => isExisting ? _handleTapExisting(usr) : _handleTapFBFriend(usr),
          child: new Container(
              height: 80.0,
              margin: const EdgeInsets.only(left: 20.0),
              //color: Colors.amber,
              child: new Row(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    padding: new EdgeInsets.only(left: 20.0),
                    //color: Colors.amber,
                    child: new Container(
                      alignment: Alignment.center,
                      width: 25.0,
                      //color: Colors.cyanAccent,
                      child: new Text(_letter,
                        style:new TextStyle(
                            fontSize:32.0,
                            fontFamily: "Montserrat-Light",
                            color: const Color(0xff1daad2)
                        ),
                      ),
                    ),
                  ),
                  new Container(
                    padding: new EdgeInsets.only(left: 30.0),
                    //color: Colors.cyanAccent,
                    child: new CircleAvatar(
                      backgroundImage: _profilePhoto,
                      radius: 20.0,
                    ),
                  ),
                  new Container(
                    padding: new EdgeInsets.only(left: 20.0),
                    //color: Colors.cyanAccent,
                    width: _screenWidth * 0.6,
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
          ),
        ));
      } else {
        _children.add(new InkWell(
          onTap: () => isExisting ? _handleTapExisting(usr) : _handleTapFBFriend(usr),
          child: new Container(
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
                      backgroundImage: _profilePhoto,
                      radius: 20.0,
                    ),
                  ),
                  new Container(
                    padding: new EdgeInsets.only(left: 20.0),
                    //color: Colors.cyanAccent,
                    //constraints: new BoxConstraints.expand(),
                    width: _screenWidth * 0.6,
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
          ),
        ));
      }
    });

    return _children;
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    String _imgAsset = "mainframe_assets/images/add_via_email.png";

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new MFAppBar("ADD PARTICIPANT", context),
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
                            child: new Form(
                                key: _formKey,
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                    //labelText: "SEARCH",
                                    hideDivider: true,
                                  ),
                                  controller: _searchCtrl,
                                  validator: _validateEmail,
                                  initialValue: "SEARCH",
                                )
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
                    onPressed: _handleAddViaEmail,
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
                      demoWidget: _buildFacebookContacts(),
                      loadMoreCallback: _loadMoreFBContacts
                  ),
                  new MFComponentDemoTabData(
                      tabName: 'CONTACTS',
                      description: '',
                      demoWidget: _buildPhoneContacts(),
                  ),
                  new MFComponentDemoTabData(
                      tabName: 'RECENT',
                      description: '',
                      demoWidget: _buildExistingContacts(),
                  ),
                ]
            ),
          )
        ],
      )
    );
  }
}
