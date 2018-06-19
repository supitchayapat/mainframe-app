import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/FormParticipantType.dart';
import 'package:myapp/src/screen/event_registration.dart' as registration;
import 'package:myapp/src/screen/solo_management.dart' as solo;
import 'package:myapp/src/screen/couple_management.dart' as coupleMgt;
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:myapp/src/util/EntryFormUtil.dart';
//import 'package:strings/strings.dart';
import '../util/StringUtil.dart';
import 'package:myapp/src/util/ShowTipsUtil.dart';

var participantType;
var groupCounter;
var participants;

class participant_list extends StatefulWidget {
  @override
  _participant_listState createState() => new _participant_listState();
}

class _participant_listState extends State<participant_list> {
  TextEditingController _searchCtrl = new TextEditingController();
  List _solo = [];
  List _couples = [];
  Map<String, dynamic> _users = {};
  var soloListener;
  var coupleListener;
  var tipsTimer;

  @override
  void initState() {
    super.initState();

    // logging for crashlytics
    global.messageLogs.add("Participants List Screen Load.");

    tipsTimer = ShowTips.showTips(context, "participantsList");

    soloParticipantsListener((users){
      //print("NUMBER OF USERS: ${users.length}");
      setState((){
        _users = {};
        _solo = [];
        _solo.addAll(users);
        users.forEach((val){
          _users.putIfAbsent("${val.first_name} ${val.last_name}", () => val);
        });
        _couples.forEach((val){
          _users.putIfAbsent("${val.coupleName}", () => val);
        });
      });
    }).then((listener) {soloListener=listener;});

    coupleParticipantsListener((couples){
      //print("NUMBER OF USERS: ${couples.length}");
      setState((){
        _users = {};
        _couples = [];
        _couples.addAll(couples);
        _solo.forEach((val){
          _users.putIfAbsent("${val.first_name} ${val.last_name}", () => val);
        });
        couples.forEach((val){
          _users.putIfAbsent("${val.coupleName}", () => val);
        });
      });
    }).then((listener){coupleListener=listener;});

    // get group counter from list
    int _ctr = 0;
    participants.forEach((_entryVal){
      //print(_entryVal.type);
      if(_entryVal?.type != null && _entryVal?.type == FormParticipantType.GROUP) {
        _ctr = _entryVal?.user?.groupNumber > _ctr ? _entryVal?.user?.groupNumber : _ctr;
      }
    });
    groupCounter = _ctr;
  }

  @override
  void dispose() {
    super.dispose();
    soloListener.cancel();
    coupleListener.cancel();
    if(tipsTimer != null)
      tipsTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _participants = [];
    _participants.add(new Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      decoration: new BoxDecoration(
        border: const Border(
          top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
          //bottom: const BorderSide(width: 1.0, color: Colors.black)
        ),
      ),
      child: new Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0),
        decoration: new BoxDecoration(
          border: const Border(
            top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
            //bottom: const BorderSide(width: 1.0, color: Colors.white)
          ),
        ),
      ),
    ));
    _users.forEach((key, val){
      String _categoryGender = "";
      if(val is User) {
        if(val.category == DanceCategory.PROFESSIONAL)
          _categoryGender = "PRO";
        else
          _categoryGender = "AM";

        if(val.gender == Gender.MAN)
          _categoryGender += " GUY";
        else
          _categoryGender += " GIRL";
      }
      else {
        _categoryGender = EntryFormUtil.getParticipantCodeOnUser(val, "couple").toString();
        _categoryGender = _categoryGender.replaceAll("FormParticipantCode.", "").replaceAll("_", " ");
      }

      _participants.add(new InkWell(
        onTap: () {
          // logging for crashlytics
          global.messageLogs.add("Selected Participant [$key]");
          setState((){
            registration.participant = {
              "name": key,
              "user": val
            };
            registration.tipsTimer = null;
          });
          Navigator.of(context).maybePop();
        },
        child: new Container(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          decoration: new BoxDecoration(
            border: const Border(
                bottom: const BorderSide(width: 1.0, color: const Color(0xFF53617C))
            ),
          ),
          child: new Container(
            padding: const EdgeInsets.only(left: 30.0, right: 20.0, bottom: 10.0, top: 10.0),
            decoration: new BoxDecoration(
              border: const Border(
                  bottom: const BorderSide(width: 2.0, color: const Color(0xFF212D44))
              ),
            ),
            //child: new Text("${key} - ${camelize(_categoryGender)}", style: new TextStyle(fontSize: 18.0)),
            child: new Wrap(
              children: <Widget>[
                new Text("${key} ", style: new TextStyle(fontSize: 18.0)),
                new Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: new Text("(${StringUtil.camelize(_categoryGender)})", style: new TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ),
        ),
      ));
    });
    /*_participants.add(new InkWell(
      onTap: () {
        participantType = "solo";
        //Navigator.of(context).pushNamed("/addPartner");
        solo.participantUser = null;
        Navigator.of(context).pushNamed("/soloManagement");
      },
      child: new Container(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        decoration: new BoxDecoration(
          border: const Border(
              bottom: const BorderSide(width: 1.0, color: const Color(0xFF53617C))
          ),
        ),
        child: new Container(
          padding: const EdgeInsets.only(left: 50.0, right: 20.0, bottom: 10.0, top: 10.0),
          decoration: new BoxDecoration(
            border: const Border(
                bottom: const BorderSide(width: 2.0, color: const Color(0xFF212D44))
            ),
          ),
          child: new Text("Create New Solo Participant ...", style: new TextStyle(fontSize: 18.0)),
        ),
      ),
    ));
    _participants.add(new InkWell(
      onTap: () {
        participantType = "couple";
        Navigator.of(context).pushNamed("/coupleManagement");
      },
      child: new Container(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        decoration: new BoxDecoration(
          border: const Border(
              bottom: const BorderSide(width: 1.0, color: const Color(0xFF53617C))
          ),
        ),
        child: new Container(
          padding: const EdgeInsets.only(left: 50.0, right: 20.0, bottom: 10.0, top: 10.0),
          decoration: new BoxDecoration(
            border: const Border(
                bottom: const BorderSide(width: 2.0, color: const Color(0xFF212D44))
            ),
          ),
          child: new Text("Create New Couple Participant...", style: new TextStyle(fontSize: 18.0)),
        ),
      ),
    ));

    _participants.add(new InkWell(
      onTap: () {
        setState((){
          groupCounter = groupCounter != null ? groupCounter+1 : 1;
          registration.participant = {
            "name": "Group ($groupCounter)",
            "user": new Group(groupName: "Group ($groupCounter)", groupNumber: groupCounter)
          };
        });
        Navigator.of(context).maybePop();
      },
      child: new Container(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        decoration: new BoxDecoration(
          border: const Border(
              bottom: const BorderSide(width: 1.0, color: const Color(0xFF53617C))
          ),
        ),
        child: new Container(
          padding: const EdgeInsets.only(left: 50.0, right: 20.0, bottom: 10.0, top: 10.0),
          decoration: new BoxDecoration(
            border: const Border(
                bottom: const BorderSide(width: 2.0, color: const Color(0xFF212D44))
            ),
          ),
          child: new Text("Group Participant", style: new TextStyle(fontSize: 18.0)),
        ),
      ),
    ));*/


    return new Scaffold(
      appBar: new AppBar(
        titleSpacing: 0.0,
        title: new Theme(
            data: new ThemeData(
              brightness: Brightness.dark
            ),
            child: new Container(
              //color: Colors.amber,
              height: 80.0,
              child: new Row(
                children: <Widget>[
                  new IconButton(icon: new Icon(Icons.arrow_back_ios), onPressed: (){Navigator.of(context).maybePop();}),
                  new Expanded(
                      child: new Container(
                        decoration: new BoxDecoration(
                            borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                            border: new Border.all(
                              width: 2.0,
                              color: const Color(0xFF313746),
                              style: BorderStyle.solid,
                            ),
                            color: Colors.white
                        ),
                        child: new Row(
                          children: <Widget>[
                            new Padding(padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                              child: new Icon(Icons.search, color: Colors.black),
                            ),
                            new Expanded(
                                child: new Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: new TextField(
                                    controller: _searchCtrl,
                                    decoration: new InputDecoration(
                                      //hideDivider: true,
                                      hintText: "Search Name",
                                      hintStyle: new TextStyle(color: Colors.black)
                                    ),
                                    style: new TextStyle(color: Colors.black, fontSize: 18.0, fontFamily: "Montserrat-Regular"),
                                  ),
                                )
                            )
                          ],
                        ),
                      )
                  )
                ],
              ),
            ),
        ),
        automaticallyImplyLeading: false
      ),
      body: new ListView(
        children: _participants,
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: (){
          showSelectionDialog(context, "CREATE NEW", 220.0, {
            "Solo Participant": "solo",
            "Couple": "couple",
            "Group Entry": "group"
          }).then((selectVal){
            switch(selectVal) {
              case 'solo':
                // logging for crashlytics
                global.messageLogs.add("Create new Solo Participant button");
                participantType = "solo";
                solo.participantUser = null;
                solo.tipsTimer = null;
                Navigator.of(context).pushNamed("/soloManagement");
                break;
              case 'couple':
                // logging for crashlytics
                global.messageLogs.add("Create new Couple Participant button");
                participantType = "couple";
                coupleMgt.couple1 = null;
                coupleMgt.couple2 = null;
                coupleMgt.tipsTimer = null;
                Navigator.of(context).pushNamed("/coupleManagement");
                break;
              case 'group':
                // logging for crashlytics
                global.messageLogs.add("Create new Group Participant button");
                setState((){
                  groupCounter = groupCounter != null ? groupCounter+1 : 1;
                  registration.participant = {
                    "name": "Group #$groupCounter",
                    "user": new Group(groupName: "Group #$groupCounter", groupNumber: groupCounter)
                  };
                });
                Navigator.of(context).maybePop();
                break;
              default:
                break;
            }
          });
        },
        tooltip: 'New',
        child: new Icon(Icons.person_add),
      ),
    );
  }
}