import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFTabComponent.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:validator/validator.dart';
import 'package:mframe_plugins/mframe_plugins.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/util/ShowTipsUtil.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:myapp/src/screen/participant_list.dart' as participant;
import 'package:myapp/src/screen/couple_management.dart' as couple;
import 'package:myapp/src/screen/solo_management.dart' as solo;
import 'package:myapp/src/screen/GroupDance.dart' as group;
import 'package:myapp/src/screen/attendee_management.dart' as attendee;
import 'package:myapp/src/util/AnalyticsUtil.dart';

var tipsTimer;
var titlePart;

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
  var _currentUser;

  @override
  void initState() {
    super.initState();

    if(titlePart == null) {
      titlePart = "PARTICIPANT";
    }

    // logging for crashlytics
    global.messageLogs.add("Add Participant Screen loaded.");
    AnalyticsUtil.setCurrentScreen("Add Participant", screenClassName: "add_dance_partner");

    //setState((){
      _searchCtrl.text = "SEARCH";
    //});
    MframePlugins.phoneContacts().then((val){
      setState(() {
        contacts = [];
        contacts.addAll(val);
      });
    });

    /*global.taggableFriends.then((usrs){
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
    });*/

    getUserExistingParticipants().then((usersData){
      setState((){
        existingUsers.addAll(usersData);
      });
    });

    getCurrentUserProfile().then((_curr){
      _currentUser = _curr;
    });
  }

  void _inviteWithEmail() {
    // logging for crashlytics
    global.messageLogs.add("Add manually button pressed.");
    AnalyticsUtil.sendAnalyticsEvent("add_manually_press", params: {
      'screen': 'add_dance_partner'
    });
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
    //global.setDancePartner = _searchCtrl.text;
    global.setDancePartner = "";
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
    /*var _ans = showMainFrameDialogWithCancel(
        context, "Invite Friend",
        "Do you want to send facebook message to ${usr.first_name} ${usr.last_name} as a Participant?")
        .then((_ans){
          if(_ans == "OK") {
            showFacebookAppShareDialog();
          }*/

          global.setDancePartner = "${usr.first_name}|${usr.last_name}";
          Navigator.of(context).pushNamed("/profilesetup-1");
    //});
  }

  void _handleTapExisting(usr) {
    // logging for crashlytics
    global.messageLogs.add("Existing User pressed [${usr.first_name} ${usr.last_name}]");
    AnalyticsUtil.sendAnalyticsEvent("existing_user_press", params: {
      'screen': 'add_dance_partner'
    });
    // TODO: will implement saving of entry form
    if(participant.participantType == "solo") {
      //MainFrameLoadingIndicator.showLoading(context);
      // save participant
      /*saveUserSoloParticipants(usr).then((_val){
        MainFrameLoadingIndicator.hideLoading(context);
        Navigator.of(context).popUntil(ModalRoute.withName("/participants"));
      });*/
      solo.participantUser = usr;
      solo.tipsTimer = null;
      Navigator.of(context).popUntil(ModalRoute.withName("/soloManagement"));
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
      couple.tipsTimer = null;
      Navigator.of(context).popUntil(ModalRoute.withName("/coupleManagement"));
    } else if(participant.participantType == "group") {
      if(group.formParticipant.members == null) {
        group.formParticipant.members = new Set<User>();
      }
      setState((){
        group.formParticipant.members.add(usr);
        Navigator.maybePop(context);
      });
    } else if(participant.participantType == "coach") {
      setState(() {
        group.formCoach = usr;
        Navigator.maybePop(context);
      });
    } else if(attendee.participantType == "attendee") {
      setState(() {
        attendee.participantUser = usr;
        attendee.tipsTimer = null;
        Navigator.of(context).popUntil(ModalRoute.withName("/attendeeManagement"));
      });
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

      if(con.contactName != null && !con.contactName.isEmpty) {
        if(_letter != _curr) {
          _letter = _curr;
          _children.add(new InkWell(
            onTap: () {
              global.messageLogs.add("User From Contacts pressed [${con.contactName}]");
              AnalyticsUtil.sendAnalyticsEvent("user_contact_press", params: {
                'screen': 'add_dance_partner'
              });
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
                            /*new Container(
                          alignment: Alignment.centerLeft,
                          child: new Text(con.contactPhone,
                            style: new TextStyle(
                              fontSize: 14.0,
                              fontFamily: "Montserrat-Light",
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),*/
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
                            /*new Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(con.contactPhone,
                              style: new TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat-Light",
                                color: const Color(0xffffffff),
                              ),
                            ),
                          ),*/
                          ],
                        )
                    ),
                  ],
                )
            ),
          ));
        }
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
      String _categoryGender = "";

      if(isExisting) {
        if (usr?.category == DanceCategory.PROFESSIONAL)
          _categoryGender = "(PRO";
        else
          _categoryGender = "(AM";

        if (usr?.gender == Gender.MAN)
          _categoryGender += " GUY)";
        else
          _categoryGender += " GIRL)";
      }

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
                    child: new Wrap(
                      children: <Widget>[
                        new Text("${usr.first_name} ${usr.last_name} ",
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Montserrat-Light",
                            color: const Color(0xffffffff),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: new Text("${_categoryGender}", style: new TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold))
                        )
                      ],
                    )
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
                    child: new Wrap(
                      children: <Widget>[
                        new Text("${usr.first_name} ${usr.last_name} ",
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Montserrat-Light",
                            color: const Color(0xffffffff),
                          ),
                        ),
                        new Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: new Text("${_categoryGender}", style: new TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold))
                        )
                      ],
                    )
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

    if(tipsTimer == null)
      tipsTimer = ShowTips.showTips(context, "addParticipant");

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new MFAppBar("ADD ${titlePart}", context),
      body: new Column(
        children: <Widget>[
          /*new Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  color: Colors.amber,
                  width: _screenWidth * 0.4,
                  padding: const EdgeInsets.only(left: 0.0, top: 5.0, bottom: 10.0, right: 15.0),
                  child: new MainFrameButton(
                    child: new Text("ADD VIA EMAIL"),
                    //imgAsset: _imgAsset,
                    onPressed: _handleAddViaEmail,
                  )
              )
            ],
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),*/
          new Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new InkWell(
                    onTap: _inviteWithEmail,
                    child: new Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      decoration: new BoxDecoration(
                        image: new DecorationImage(image: new ExactAssetImage("mainframe_assets/images/button_mds.png")),
                      ),
                      height: 40.0,
                      child: new Center(child: new Text("ADD MANUALLY", style: new TextStyle(fontSize: 17.0))),
                    ),
                  )
                ),
                new InkWell(
                  onTap: (){
                    // logging for crashlytics
                    global.messageLogs.add("Assign me button pressed.");
                    AnalyticsUtil.sendAnalyticsEvent("assign_me_press", params: {
                      'screen': 'add_dance_partner'
                    });
                    if(_currentUser != null) {
                      _handleTapExisting(_currentUser);
                    }
                  },
                  child: new Container(
                    margin: new EdgeInsets.only(right: 5.0, left: 5.0),
                    decoration: new BoxDecoration(
                        borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                        border: new Border.all(
                          color: Colors.black,
                          style: BorderStyle.solid,
                        )
                    ),
                    width: 135.0,
                    height: 36.0,
                    child: new Container(
                      alignment: Alignment.center,
                      color: const Color(0xffffffff),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Icon(Icons.person_add, color: Colors.black),
                          new Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: new Text("ASSIGN ME",
                              style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ),
          new Flexible(
            child: new MFTabbedComponentDemoScaffold(
                demos: <MFComponentDemoTabData>[
                  /*new MFComponentDemoTabData(
                      tabName: 'FACEBOOK',
                      description: '',
                      demoWidget: _buildFacebookContacts(),
                      loadMoreCallback: _loadMoreFBContacts
                  ),*/
                  new MFComponentDemoTabData(
                    tabName: 'RECENT',
                    description: '',
                    demoWidget: _buildExistingContacts(),
                  ),
                  new MFComponentDemoTabData(
                      tabName: 'CONTACTS',
                      description: '',
                      demoWidget: _buildPhoneContacts(),
                  ),
                ]
            ),
          )
        ],
      )
    );
  }
}
