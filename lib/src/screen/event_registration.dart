import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:quiver/core.dart';
import 'package:myapp/src/screen/entry_summary.dart' as summary;
import 'package:myapp/src/screen/entry_form_a24.dart' as formScreen;
import 'package:myapp/src/screen/entry_freeform.dart' as freeFormScreen;
import 'package:myapp/src/screen/GroupDance.dart' as groupFormScreen;
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/util/EntryFormUtil.dart';
import 'package:myapp/src/enumeration/FormParticipantType.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/enumeration/FormType.dart';
import 'package:myapp/src/dao/EventEntryDao.dart';
import 'package:myapp/src/freeform/ShowDanceSolo.dart';
import 'participant_list.dart' as partList;

var eventItem;
var participant;

class EventParticipant {
  String name;
  var type; // solo, couple, group
  var user;
  List formEntries;
  bool toggle;

  EventParticipant({this.name, this.type, this.user, this.toggle : false});

  void addFormEntry(entry) {
    formEntries.add(entry);
  }

  bool operator ==(o) => o is EventParticipant && o.name == name && o.type == type;
  int get hashCode => hash2(name.hashCode, type.hashCode);
}

class event_registration extends StatefulWidget {
  @override
  _event_registrationState createState() => new _event_registrationState();
}

class _event_registrationState extends State<event_registration> {
  var entryListener;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<EventParticipant, Map<String, int>> _participantEntries = {};
  Set<EventParticipant> _participants = new Set();
  Map<String, dynamic> _eventEntries = {};
  /*Map<String, String> _entryForms = {
    'Showdance Solo': 'couple',
    'Future Celebrities Competition Kids': 'couple',
    'Group Dance Competition': 'group',
    'Adult Showcase Single Dance': 'couple',
    'Amateur Competition': 'couple',
    'Adult Multi-Dance Competition': 'couple',
  };*/
  List _entryForms = [];

  @override
  void initState() {
    super.initState();

    if(eventItem.formEntries != null) {
      //eventItem.formEntries.forEach((val) => print(val.toJson()));
      _entryForms = eventItem.formEntries;
      print("Event Id: ${eventItem.id} entry forms: ${_entryForms.length}");
    }

    // retrieve participants with entries
    EventEntryDao.getEventEntry(eventItem.id, (_evtParticipantEntries){
      setState((){
        _eventEntries = {};
        _participantEntries = {};
        if(_evtParticipantEntries != null) {
          _evtParticipantEntries.forEach((_pushId, _partEntries) {
            /*print("Participant Event:");
        print(_partEntries?.event?.toJson());
        print("Participant Form:");
        print(_partEntries?.formEntry?.toJson());
        print("Participant user:");
        print(_partEntries?.participant?.toJson());*/
            // add participant(s)
            if (_partEntries?.participant != null) {
              String evtPartName = "";
              var _usr = _partEntries.participant;
              var _type;
              if (_usr is Couple) {
                _type = FormParticipantType.COUPLE;
                evtPartName = _usr.coupleName;
              }
              else if (_usr is Group) {
                _type = FormParticipantType.GROUP;
                evtPartName = _usr.groupName;
              } else {
                _type = FormParticipantType.SOLO;
                evtPartName = "${_usr?.first_name} ${_usr?.last_name}";
              }
              EventParticipant _p = new EventParticipant(
                  name: evtPartName,
                  user: _usr,
                  type: _type);
              _participants.add(_p);

              // add participant entries
              String _frmName = _partEntries?.formEntry?.name;
              int _danceEntries = _partEntries?.danceEntries;
              /*if(_partEntries?.paidEntries != null) {
                print("paid: ${_partEntries?.paidEntries}");
                _danceEntries -= _partEntries?.paidEntries;
              }*/
              Map<String, int> _pe = {};
              if (!_participantEntries.containsKey(_p)) {
                _pe.putIfAbsent(_frmName, () => _danceEntries);
                _participantEntries.putIfAbsent(_p, () => _pe);
              } else {
                _pe = _participantEntries[_p];
                _pe.putIfAbsent(_frmName, () => _danceEntries);
              }
            }

            _eventEntries.putIfAbsent(_pushId, () => _partEntries);
          });
        }
      });
    }).then((listener) {entryListener = listener;});
  }

  @override
  void dispose() {
    super.dispose();
    entryListener.cancel();
  }

  void _handleAddEventParticipant() {
    if(participant != null) {
      setState(() {
        var _usr = participant["user"];
        var _type;
        if(_usr is Couple) {
          _type = FormParticipantType.COUPLE;
        }
        else if(_usr is Group) {
          _type = FormParticipantType.GROUP;
        }
        else {
          _type = FormParticipantType.SOLO;
        }
        EventParticipant _p = new EventParticipant(
            name: participant["name"], user: participant["user"], type: _type);
        int _entryFormCount = 0;

        _entryForms.forEach((_form){
          if(EntryFormUtil.isFormApplicable(_form, _p.user, _p.type)) {
            _entryFormCount += 1;
          }
        });

        if(_entryFormCount > 0) {
          _participants.add(_p);
        }
        else {
          showMainFrameDialog(context, "Entry not allowed", "Selected Participant has no available entries for the event.");
        }
      });
    }
  }

  Widget _generateEntryItem(EventParticipant _evtParticipant) {
    Map<String, int> _entryItems = {};
    Map<String, dynamic> _entryData = {};
    Widget _entryChild;

    if(_participantEntries.containsKey(_evtParticipant)) {
      _entryItems = _participantEntries[_evtParticipant];
    }

    if(!_evtParticipant.toggle) {
      _entryChild = new Row(
        crossAxisAlignment: _evtParticipant.toggle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(child: new Padding(padding: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0), child: new Text(_evtParticipant.name, style: new TextStyle(fontSize: 16.0, color: Colors.black)))),
          new Container(
            width: 25.0,
            child: _evtParticipant.toggle ? new Icon(Icons.keyboard_arrow_down, color: Colors.black) : new Icon(Icons.keyboard_arrow_right, color: Colors.black),
          )
        ],
      );
    }
    else {
      List<Widget> _formButtons = [];
      _entryForms.forEach((val){
        //print("${val.formName} --- ${_evtParticipant.type}");
        if(EntryFormUtil.isFormApplicable(val, _evtParticipant.user, _evtParticipant.type)) {
          _formButtons.add(new Row(
            crossAxisAlignment: _evtParticipant.toggle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                child: new Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: new BoxDecoration(
                      borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                      border: new Border.all(
                        width: 2.0,
                        color: const Color(0xFF313746),
                        style: BorderStyle.solid,
                      )
                  ),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new MaterialButton(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        minWidth: 5.0, height: 40.0,
                        color: Colors.white,
                        onPressed: () {
                          bool hasDataEntry = false;
                          if(_eventEntries != null) {
                            _eventEntries.forEach((_pushId, _entryVal){
                              if(_entryVal.formEntry.name == val.name && _entryItems[val.name] != null) {
                                if(val.type == FormType.STANDARD) {
                                  formScreen.formData = _entryVal.levels;
                                  formScreen.formPushId = _pushId;
                                  hasDataEntry = true;
                                } else if(val.type == FormType.SOLO) {
                                  freeFormScreen.formData = _entryVal.freeForm;
                                  freeFormScreen.formPushId = _pushId;
                                  hasDataEntry = true;
                                } else {
                                  groupFormScreen.formData = _entryVal.freeForm;
                                  print("reg: ${_entryVal.freeForm}");
                                  groupFormScreen.formPushId = _pushId;
                                  hasDataEntry = true;
                                }
                              }
                            });
                          }
                          if(!hasDataEntry) {
                            formScreen.formData = null;
                            formScreen.formPushId = null;
                            freeFormScreen.formData = null;
                            freeFormScreen.formPushId = null;
                            groupFormScreen.formData = null;
                            groupFormScreen.formPushId = null;
                          }
                          if(val.type == FormType.STANDARD) {
                            /*int numItem = _entryItems.containsKey(val.formName)
                                ? _entryItems[val.formName]
                                : 0;
                            //print("NUM: $numItem");
                            setState(() {
                              if (_entryItems.containsKey(val.formName)) {
                                _entryItems.remove(val.formName);
                              }
                              else {
                                _entryItems.putIfAbsent(
                                    val.formName, () => (numItem + 1));
                              }
                              _participantEntries.putIfAbsent(
                                  _evtParticipant, () => _entryItems);
                            });
                            print(_participantEntries);
                            */
                            formScreen.formEntry = val;
                            formScreen.formParticipant = _evtParticipant.user;
                            //formScreen.formData = _entryData[val.name] != null ? _entryData[val.name] : null;
                            Navigator.of(context).pushNamed("/entryForm");
                          }
                          else if(val.type == FormType.SOLO) {
                            freeFormScreen.formEntry = val;
                            freeFormScreen.formParticipant = _evtParticipant.user;
                            //if(val.type == FormType.SOLO) {
                              freeFormScreen.freeFormObj = new ShowDanceSolo();
                            //}
                            Navigator.of(context).pushNamed("/entryFreeForm");
                          }
                          else {
                            groupFormScreen.formEntry = val;
                            groupFormScreen.formParticipant = _evtParticipant.user;
                            groupFormScreen.formCoach = null;
                            Navigator.of(context).pushNamed("/entryGroupForm");
                          }
                        },
                        child: new Container(
                          alignment: Alignment.centerLeft,
                          child: new Row(
                            children: <Widget>[
                              new Expanded(
                                  child: new Text("${val.name}",
                                    style: new TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black,
                                    ),
                                  )
                              ),
                              _entryItems.containsKey(val.name) ? new CircleAvatar(
                                radius: 14.0,
                                backgroundColor: const Color(0xFF778198),
                                child: new Text(_entryItems[val.name].toString(),
                                  style: new TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ) : new Container()
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ));
        }
      });
      
      if(_formButtons.length <= 0 ) {
        _formButtons.add(new Container(
          margin: const EdgeInsets.only(left: 10.0),
          child: new Text(" - No available Entry Form(s)",
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.black,
              fontStyle: FontStyle.italic
            ),
          ),
        ));
      }
      
      _entryChild = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Row(
            crossAxisAlignment: _evtParticipant.toggle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(child: new Padding(padding: const EdgeInsets.only(left: 10.0, top: 10.0), child: new Text(_evtParticipant.name, style: new TextStyle(fontSize: 16.0, color: Colors.black)))),
              new Container(
                width: 25.0,
                child: _evtParticipant.toggle ? new Icon(Icons.keyboard_arrow_down, color: Colors.black) : new Icon(Icons.keyboard_arrow_right, color: Colors.black),
              )
            ],
          ),
          new Column(
            children: _formButtons,
          )
        ],
      );
    }

    return new InkWell(
      onTap: (){
        setState((){
          if(!_evtParticipant.toggle)
            _evtParticipant.toggle = true;
          else
            _evtParticipant.toggle = false;
        });
      },
      child: new Container(
        decoration: new BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
        //height: _evtParticipant.toggle ? 155.0 : 55.0,
        child: _entryChild,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/add_via_email.png";

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new MFAppBar("REGISTRATION", context),
      body: new ListView(
        children: <Widget>[
          /*new Container(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            decoration: new BoxDecoration(
              border: const Border(
                top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                //bottom: const BorderSide(width: 1.0, color: Colors.black)
              ),
            ),
            child: new Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
              decoration: new BoxDecoration(
                border: const Border(
                  top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                  //bottom: const BorderSide(width: 1.0, color: Colors.white)
                ),
              ),
              child: new Text("Participant(s)", style: new TextStyle(fontSize: 18.0)),
            ),
          ),*/
          new Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
              child: new Theme(
                  data: new ThemeData(
                      brightness: Brightness.light
                  ),
                  child: new MaterialButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: (){
                        participant = null;
                        partList.participants = _participants;
                        Navigator.of(context).pushNamed("/participants");
                      },
                      child: new Container(
                        height: 50.0,
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
                                child: new Text(participant != null ? participant["name"] : "Select Participant(s)", style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                              ),
                              new Icon(Icons.search, color: Colors.black)
                            ],
                          ),
                        ),
                      ),
                  )
              )
          ),
          new Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
            child: new MainFrameButton(
              child: new Text("ADD TO EVENT"),
              onPressed: (){
                _handleAddEventParticipant();
              },
            ),
          ),
          new Container(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            decoration: new BoxDecoration(
              border: const Border(
                top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
              ),
            ),
            child: new Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              decoration: new BoxDecoration(
                border: const Border(
                  top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                ),
              ),
            ),
          ),
          new Column(
            children: _participants.map((val){
              return _generateEntryItem(val);
            }).toList(),
          )
        ],
      ),
      floatingActionButton: new InkWell(
        onTap: (){
          if(_participantEntries.length > 0) {
            //print(_participantEntries);
            summary.participantEntries = _participantEntries;
            summary.eventEntries = _eventEntries;
            Navigator.of(context).pushNamed("/registrationSummary");
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
          child: new Text("Proceed", style: new TextStyle(fontSize: 17.0)),
        ),
      )
    );
  }
}