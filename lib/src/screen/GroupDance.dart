import 'dart:collection';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/model/EventEntry.dart';
import 'package:myapp/src/model/UserEvent.dart';
import 'package:myapp/src/dao/EventEntryDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/util/ShowTipsUtil.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/src/dao/TicketDao.dart';
import 'participant_list.dart' as participantList;
import 'event_registration.dart' as registration;
import 'add_dance_partner.dart' as addPartner;
import 'package:myapp/MFGlobals.dart' as global;

var formEntry;
var formParticipant;
var formData;
var formPushId;
var formCoach;
var paidEntries;

class GroupDance extends StatefulWidget {
  @override
  _GroupDanceState createState() => new _GroupDanceState();
}

class _GroupDanceState extends State<GroupDance> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _danceCtrl = new TextEditingController();
  String titlePage = "";
  var _dataMap;
  bool isPaid = false;
  var tipsTimer;
  Set<String> _initMembers;

  @override
  void initState() {
    super.initState();
    _initMembers = new Set();

    print("FORM SESSION CODE: ${formEntry.sessionCode}");

    // logging for crashlytics
    global.messageLogs.add("Group Entry form screen loaded.");
    AnalyticsUtil.setCurrentScreen("Group Entry Form", screenClassName: "GroupDance");

    //_dataMap = new HashMap();

    tipsTimer = ShowTips.showTips(context, "groupDance");

    if (formEntry != null && formEntry.name != null) {
      titlePage = formEntry.name;
    }

    if(paidEntries != null && paidEntries > 0) {
      isPaid = true;
    }

    if(formData != null) {
      _dataMap = formData;
      if(_dataMap.containsKey("danceCoach")) {
        formCoach = new User.fromDataSnapshot(_dataMap["danceCoach"]);
      }
      _danceCtrl.text = _dataMap["danceTitle"];
    } else {
      _dataMap = new HashMap<dynamic, dynamic>();
    }

    // a set of group member names
    if(formParticipant?.members != null && formParticipant?.members?.length > 0) {
      for(var membr in formParticipant.members) {
        _initMembers.add("${membr.first_name} ${membr.last_name}");
      }
    }
    print("init members: $_initMembers");
  }

  Future _handleBackButton() async {
    if(!isPaid && formParticipant?.members != null) {
      var val = await showMainFrameDialogWithCancel(
          context, "Form Entry", "Save Changes on ${formEntry.name}?");
      if (val == "OK") {
        _handleSaving();
      }
      else {
        Navigator.of(context).maybePop();
      }
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleSaving() {
    Set<String> _finalMembers = new Set();
    if(formParticipant?.members != null && formParticipant?.members?.length > 0) {
      for(var membr in formParticipant.members) {
        _finalMembers.add("${membr.first_name} ${membr.last_name}");
      }
    }
    print("final Members: ${_finalMembers}");
    Set<String> _diff1 = new Set();
    _diff1.addAll(_initMembers);
    _diff1.removeAll(_finalMembers);
    print("DIFF: $_diff1");

    if((_dataMap["danceTitle"] != null && _dataMap["danceTitle"].isNotEmpty)
        && formCoach != null) {
      // logging for crashlytics
      global.messageLogs.add("Saving entry form.");
      AnalyticsUtil.sendAnalyticsEvent("saving_entry_form", params: {
        'screen': 'GroupDance'
      });
      print("saving datamap: $_dataMap");

      Map freeform = {};
      freeform.addAll(_dataMap);
      freeform["danceCoach"] = formCoach.toJson();

      EventEntry entry = new EventEntry(
          formEntry: formEntry,
          //event: registration.eventItem,
          participant: formParticipant,
          levels: [],
          danceEntries: 1,
          freeForm: freeform
      );

      UserEvent userEvent = new UserEvent(
        info: registration.eventItem,
        usrEntryForm: entry
      );
      if(formPushId != null) {
        EventEntryDao.updateEventEntry(formPushId, userEvent);
      } else {
        EventEntryDao.saveEventEntry(userEvent);
      }

      // add tickets
      for(var _m in _finalMembers) {
        TicketDao.autoAddCompetitorTickets(registration.eventItem, formEntry.sessionCode, _m);
      }
      // remove tickets
      for(var _m in _diff1) {
        TicketDao.autoRemoveCompetitorTickets(registration.eventItem, formEntry.sessionCode, _m);
      }

      _clearInputs();
      Navigator.of(context).maybePop();
    }
    else {
      showMainFrameDialog(context, "Save Entry Failed", "Must assign Dance Coach and Dance Title.");
    }
  }

  void _clearInputs() {
    formEntry = null;
    formParticipant = null;
    formData = null;
    formPushId = null;
    formCoach = null;
  }

  List<Widget> _generateGroupMembers() {
    if(formParticipant?.members != null && formParticipant?.members?.length > 0) {
      return formParticipant.members.map<Widget>((member){
        return new Container(
          padding: const EdgeInsets.all(5.0),
          decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
              border: new Border.all(
                width: 2.0,
                color: const Color(0xFF313746),
                style: BorderStyle.solid,
              )
          ),
          child: new Wrap(
            children: <Widget>[
              new Text("${member.first_name} ${member.last_name}",
                style: new TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              new Padding(padding: const EdgeInsets.only(left: 4.0)),
              new InkWell(
                onTap: (){
                  setState((){formParticipant.members.remove(member);});
                },
                child: new Icon(Icons.cancel, color: Colors.black),
              )
            ],
          ),
        );
      }).toList();
    } else {
      return [new Text("Add Group Members", style: new TextStyle(fontSize: 17.0, color: Colors.black))];
    }
  }

  List<Widget> _generateInputs() {
    List<Widget> _children = [];

    if(formEntry?.structure?.verticals != null) {
      formEntry.structure.verticals.forEach((_vert){
        //print(_vert?.toJson());
        var _formLookup = formEntry.getFormLookup(_vert.link);
        //print(_formLookup?.description);
        if(_formLookup?.description != null) {
          String _idx = _formLookup.description.toString().toLowerCase().replaceAll(" ", "_");
          _dataMap.putIfAbsent(_idx, () => _formLookup.elements[0].content);
          List<String> _elementItems = [];

          _formLookup?.elements?.forEach((_elem){
            _elementItems.add(_elem.content);
          });
          //print(_elementItems);

          _children.add(new Container(
            //color: Colors.amber,
            margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
            child: new Text(
                _formLookup?.description, style: new TextStyle(fontSize: 18.0)),
          ));
          if(_elementItems.length > 1) {
            _children.add(new Theme(
                data: new ThemeData(
                    brightness: Brightness.light
                ),
                child: new DropdownButtonHideUnderline(
                    child: new Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        color: Colors.white,
                        child: new DropdownButton(
                            iconSize: 30.0,
                            value: _dataMap[_idx],
                            items: _elementItems.map<DropdownMenuItem>((String value) {
                              return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value));
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                if (val != null)
                                  _dataMap[_idx] = val;
                              });
                            }
                        )
                    )
                )
            ));
          } else if(_elementItems.length == 1) {
            _children.add(new Container(
              //color: Colors.amber,
              margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
              child: new Text(
                  " - ${_elementItems[0]}", style: new TextStyle(fontSize: 18.0)),
            ));
          }
        }
      });
      return _children;
    } else {
      return _children;
    }
  }

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/add_via_email.png";
    List<Widget> _children = [];
    _children.add(new InkWell(
      //padding: const EdgeInsets.all(0.0),
      onTap: (){
        if(!isPaid) {
          participantList.participantType = "group";
          addPartner.tipsTimer = null;
          Navigator.of(context).pushNamed("/addPartner");
        }
      },
      child: new Container(
          constraints: const BoxConstraints(minHeight: 50.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
              border: new Border.all(
                width: 2.0,
                color: const Color(0xFF313746),
                style: BorderStyle.solid,
              ),
              color: Colors.white
          ),
          child: new Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                  child: new Wrap(
                    spacing: 4.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    children: _generateGroupMembers(),
                  ),
                ),
                new Icon(Icons.person_add, color: Colors.black),
              ],
            ),
          )
      ),
    ));

    // dance coach
    //print("before: $_dataMap");
    /*if(formCoach != null) {
      if (!_dataMap.containsKey("danceCoach")) {
        print("formCoach: $formCoach");
        _dataMap.putIfAbsent("danceCoach", () => 11);
      } else {
        _dataMap["danceCoach"] = 11;
      }
    }
    else if(formCoach == null && _dataMap["danceCoach"] != null) {
      setState((){
        formCoach = new User.fromDataSnapshot(_dataMap["danceCoach"]);
      });
    }*/
    //print(_dataMap);

    _children.add(
      new Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(top: 10.0),
        child: new Text("Dance Coach *", style: new TextStyle(fontSize: 18.0)),
      ),
    );
    _children.add(new Container(
      padding: const EdgeInsets.only(top: 10.0),
      child: new Container(
        decoration: new BoxDecoration(
            borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
            border: new Border.all(
              width: 2.0,
              color: const Color(0xFF313746),
              style: BorderStyle.solid,
            )
        ),
        child: new MaterialButton(
          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, right: 10.0, left: 20.0),
          minWidth: 5.0, height: 5.0,
          color: Colors.white,
          onPressed: () {
            participantList.participantType = "coach";
            addPartner.titlePart = "COACH";
            Navigator.of(context).pushNamed("/addPartner");
          },
          child: new Container(
            alignment: Alignment.centerLeft,
            child: new Text(formCoach == null ? "ASSIGN" : "${formCoach.first_name} ${formCoach.last_name}",
              style: new TextStyle(
                  fontSize: 17.0,
                  color: Colors.black
              ),
            ),
          )
        ),
      )
    ));

    // dance title
    _children.add(
      new Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(top: 10.0),
        child: new Text("Dance Title *", style: new TextStyle(fontSize: 18.0)),
      ),
    );
    _children.add(
      new Container(
        color: Colors.white,
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(top: 10.0),
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, right: 10.0, left: 20.0),
        child: new TextField(
          controller: _danceCtrl,
          style: new TextStyle(color: Colors.black, fontSize: 18.0),
          decoration: null,
          onChanged: (String val) {
            setState((){
              if(!_dataMap.containsKey("danceTitle"))
                _dataMap.putIfAbsent("danceTitle", () => val);
              else
                _dataMap["danceTitle"] = val;
            });
          },
        ),
      ),
    );

    // generate inputs
    _children.addAll(_generateInputs());

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new MFAppBar(titlePage, context, backButtonFunc: _handleBackButton),
      body: new Form(
          key: _formKey,
          child: new ListView(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            children: _children,
          )
      ),
      floatingActionButton: !isPaid ? new InkWell(
        onTap: () {
          // logging for crashlytics
          global.messageLogs.add("Save button pressed.");
          AnalyticsUtil.sendAnalyticsEvent("save_button_pressed", params: {
            'screen': 'GroupDance'
          });
          if(!isPaid && formParticipant?.members != null) {
            _handleSaving();
          } else {
            showMainFrameDialog(context, "Save Entry Failed", "Must assign Group Members first.");
          }
        },
        child: new Container(
          //color: Colors.amber,
          width: 100.0,
          height: 40.0,
          alignment: Alignment.center,
          decoration: new BoxDecoration(
            image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
          ),
          child: new Text("Save Entry", style: new TextStyle(fontSize: 17.0)),
        ),
      ) : new Container()
    );
  }
}