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
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:myapp/src/dao/TicketDao.dart';
import 'participant_list.dart' as partList;
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/screen/ticket_summary_a60.dart' as ticketSummary;
//import 'package:strings/strings.dart';
import '../util/StringUtil.dart';
import 'package:myapp/src/util/ShowTipsUtil.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/src/dao/AdminNotifDao.dart';

var eventItem;
var participant;
var tipsTimer;

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

  toJson() {
    return {
      "name": name,
      "type": type,
      "user": user.toJson(),
    };
  }

  bool operator ==(o) {
    return o is EventParticipant && o.name == name && o.type == type && o.user == user;
  }

  int get hashCode {
    //print("name hash: ${name.hashCode}");
    //print("type hash: ${type.hashCode}");
    return hash2(name.hashCode, type.hashCode);
  }
}

class event_registration extends StatefulWidget {
  @override
  _event_registrationState createState() => new _event_registrationState();
}

class _event_registrationState extends State<event_registration> {
  var entryListener;
  var ticketListener;
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

  void _initSummary() {
    summary.participantTickets = null;
    summary.admissionTickets = null;
    summary.ticketUsers = null;
  }

  @override
  void initState() {
    super.initState();

    // logging for crashlytics
    global.messageLogs.add("Event Registration Load.");
    AnalyticsUtil.setCurrentScreen("Event Registration", screenClassName: "event_registration");

    _initSummary();

    //print("participantTickets ${summary.participantTickets}");
    tipsTimer = ShowTips.showTips(context, "registration");

    if(eventItem.formEntries != null) {
      //eventItem.formEntries.forEach((val) => print(val.toJson()));
      _entryForms = eventItem.formEntries;
      //print("Event Id: ${eventItem.id} entry forms: ${_entryForms.length}");
      var _admission = eventItem.admission;
      if(_admission?.tickets != null && _admission.tickets.length > 0) {
        summary.admissionTickets = [];
        summary.admissionTickets.addAll(_admission.tickets);
        //summary.admissionTickets.forEach((val) => print(val.toJson()));
      }
    }

    // retrieve participants with entries
    EventEntryDao.getEventEntry(eventItem, (_evtParticipantEntries){
      //print("participant Entries: ${_evtParticipantEntries.length}");
      setState((){
        _eventEntries = {};
        _participantEntries = {};
        _participants = new Set();
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
              //print(_p?.toJson());
              //print(_participants.contains(_p));
              _participants.add(_p);
              //print(_participants.length);

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

          if(_participantEntries.length > 0) {
            if(tipsTimer != null) {
              tipsTimer.cancel();
              //print("show reg entries");
              tipsTimer = ShowTips.showTips(context, "registrationEntries");
            }
          }

          // listener
          _handleTicketListen();
        }
      });
    }).then((listener) {entryListener = listener;});
  }

  void _handleTicketListen() {
    if(_participantEntries != null && _participantEntries.isNotEmpty && ticketListener == null) {
      TicketDao.getTickets(eventItem, (_evtTickets){
        if(_evtTickets != null && _evtTickets.length > 0) {
          summary.ticketUsers = {}; // paid tickets
          Map unpaidTicketUsers = {};
          _evtTickets.forEach((_pushId, _evtTicket){
            //("owner: ${_evtTicket.ticketOwner}");
            //print("isPaid: ${_evtTicket?.ticket?.isPaid}");
            if(_evtTicket.ticketOwner != null && _evtTicket?.ticket?.isPaid != null && _evtTicket.ticket.isPaid) {
              summary.ticketUsers.putIfAbsent(_evtTicket.ticketOwner, () => _evtTicket.ticket);
            } else if(_evtTicket?.ticket?.isPaid == null || !_evtTicket.ticket.isPaid) {
              unpaidTicketUsers.putIfAbsent(_evtTicket.ticketOwner, () => _evtTicket.ticket);
            }
          });
          //print("TICKET USERS: ${summary.ticketUsers}");
          /*_ticketUsers.forEach((_k,_v){
            print("_k: ${_k?.toJson()}");
            print("_v: ${_v?.toJson()}");
          });*/

          //print("POPULATE TICKETS");
          if(_participantEntries != null && _participantEntries.isNotEmpty) {
            summary.participantTickets = {};
            _participantEntries.forEach((_participant, val) {
              //print("participant: ${_participant?.toJson()}");
              populateParticipantTickets(_participant, summary.ticketUsers);
            });
            // populate unpaid
            unpaidTicketUsers.forEach((_usr, _tck){
              summary.participantTickets[_usr] = _tck;
            });
            /*if(summary.participantTickets.isEmpty && summary.ticketUsers.isNotEmpty) {
              summary.participantTickets = {};
            } else if(summary.participantTickets.isEmpty) {
              summary.participantTickets = null;
            }*/
          }
          /*print("PTICKETS:");
          if(summary.participantTickets != null) {
            summary.participantTickets.forEach((part, val) {
              print(part?.toJson());
              if (!(val is Map))
                print(val?.toJson());
              else
                print(val);
            });
          }*/
        }
      }).then((val) { ticketListener = val; });
    } else {
      if((_participantEntries == null || _participantEntries.isEmpty) && ticketListener != null) {
        ticketListener.cancel();
      }
    }
  }

  void populateParticipantTickets(_participant, Map ticketMap) {
    if(_participant.user is Couple) {
      Map _couple = {};
      var ticketCouple1 = (ticketMap != null && ticketMap.isNotEmpty) ? ticketMap[_participant.user.couple[0]] : null;
      var ticketCouple2 = (ticketMap != null && ticketMap.isNotEmpty) ? ticketMap[_participant.user.couple[1]] : null;
      if(ticketMap == null || !ticketMap.containsKey(_participant.user.couple[0]))
        summary.participantTickets.putIfAbsent(_participant.user.couple[0], () => (ticketCouple1 != null ? ticketCouple1 : summary.admissionTickets[0]));
      if(ticketMap == null || !ticketMap.containsKey(_participant.user.couple[1]))
        summary.participantTickets.putIfAbsent(_participant.user.couple[1], () => (ticketCouple2 != null ? ticketCouple2 : summary.admissionTickets[0]));
    }
    else if(_participant.user is Group) {
      Map _members = {};
      for(var _member in _participant.user.members) {
        var memberTicket = (ticketMap != null && ticketMap.isNotEmpty) ? ticketMap[_member] : null;
        if(ticketMap == null || !ticketMap.containsKey(_member))
          summary.participantTickets.putIfAbsent(_member, () => (memberTicket != null ? memberTicket : summary.admissionTickets[0]));
      }
    } else {
      //print("participant: ${_participant?.user?.toJson()}");
      var participantTicket = (ticketMap != null && ticketMap.isNotEmpty) ? ticketMap[_participant.user] : null;
      //print("participantTicket: ${participantTicket?.toJson()}");
      if(ticketMap == null || !ticketMap.containsKey(_participant.user))
        summary.participantTickets.putIfAbsent(_participant.user, () => (participantTicket != null ? participantTicket : summary.admissionTickets[0]));
      //print("THE TICKET: ${participantTickets[_participant]?.toJson()}");
    }
  }

  @override
  void dispose() {
    super.dispose();
    entryListener.cancel();
    if(tipsTimer != null)
      tipsTimer.cancel();
    tipsTimer = null;
    if(ticketListener != null)
      ticketListener.cancel();
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
          if(!_participants.contains(_p)) {
            _participants.add(_p);
            participant = null;
            tipsTimer = ShowTips.showTips(context, "registrationEntries");
          } else {
            showMainFrameDialog(context, "Entry not allowed", "Selected Participant already added to the event.");
          }
        }
        else {
          showMainFrameDialog(context, "Entry not allowed", "Selected Participant has no available entries for the event.");
        }
      });
    } else {
      showMainFrameDialog(context, "Participant(s) field empty", "No Selected Participant(s).");
    }
  }

  Widget _generateEntryItem(EventParticipant _evtParticipant) {
    Map<String, int> _entryItems = {};
    Map<String, dynamic> _entryData = {};
    Widget _entryChild;
    String _categoryGender = "";

    if(_evtParticipant.user is User) {
      if(_evtParticipant.user.category == DanceCategory.PROFESSIONAL)
        _categoryGender = "(PRO";
      else
        _categoryGender = "(AM";

      if(_evtParticipant.user.gender == Gender.MAN)
        _categoryGender += " GUY)";
      else
        _categoryGender += " GIRL)";
    }
    else if(_evtParticipant.user is Couple) {
      _categoryGender = EntryFormUtil.getParticipantCodeOnUser(_evtParticipant.user, "couple").toString();
      _categoryGender = "("+_categoryGender.replaceAll("FormParticipantCode.", "").replaceAll("_", " ")+")";
    }

    if(_participantEntries.containsKey(_evtParticipant)) {
      _entryItems = _participantEntries[_evtParticipant];
    }

    if(!_evtParticipant.toggle) {
      _entryChild = new Row(
        crossAxisAlignment: _evtParticipant.toggle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(
              child: new Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 15.0, bottom: 15.0),
                child: new Wrap(
                  children: <Widget>[
                    new Text("${_evtParticipant.name} ", style: new TextStyle(fontSize: 16.0, color: Colors.black)),
                    new Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: new Text("${StringUtil.camelize(_categoryGender)}", style: new TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              )
          ),
          new Container(
            width: 25.0,
            child: _evtParticipant.toggle ? new Icon(Icons.keyboard_arrow_down, color: Colors.black) : new Icon(Icons.keyboard_arrow_right, color: Colors.black),
          )
        ],
      );
    }
    else {
      List<Widget> _formButtons = [];
      bool grpDisable = false;
      if(_evtParticipant.user is Group) {
        _eventEntries.forEach((_pushId, _entryVal){
          if(_entryVal.formEntry.type == FormType.GROUP && _evtParticipant.name == _entryVal.participant.groupName) {
            //print("evtParticipant: ${_evtParticipant.name} = ${_entryVal.participant.groupName}");
            grpDisable = true;
          }
        });
      }

      _entryForms.forEach((val){
        bool grpBtnDisable = false;
        if(val.type == FormType.GROUP && grpDisable && !_entryItems.containsKey(val.name)) {
          //print("${val.name} contains = ${_entryItems.containsKey(val.name)}");
          grpBtnDisable = true;
        }

        //print("${val.formName} --- ${_evtParticipant.type}");
        if(!grpBtnDisable && EntryFormUtil.isFormApplicable(val, _evtParticipant.user, _evtParticipant.type)) {
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
                      ),
                  ),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new MaterialButton(
                        //padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 20.0, right: 2.0),
                        minWidth: 5.0, height: 40.0,
                        color: Colors.white,
                        onPressed: () {
                          // logging for crashlytics
                          global.messageLogs.add("Entry form button pressed.");
                          AnalyticsUtil.sendAnalyticsEvent("entry_form_press", params: {
                            'screen': 'event_registration'
                          });
                          bool hasDataEntry = false;
                          if(_eventEntries != null) {
                            _eventEntries.forEach((_pushId, _entryVal){
                              if(_entryVal.formEntry.name == val.name
                                  && _entryItems[val.name] != null
                                  && _evtParticipant.user == _entryVal.participant) {
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
                                  //print("reg: ${_entryVal.paidEntries}");
                                  groupFormScreen.formPushId = _pushId;
                                  groupFormScreen.paidEntries = _entryVal.paidEntries;
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
                            groupFormScreen.paidEntries = null;
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
                          //color: Colors.amber,
                          alignment: Alignment.centerLeft,
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new Expanded(
                                  child: new Text("${val.name}",
                                    style: new TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black,
                                    ),
                                  )
                              ),
                              _entryItems.containsKey(val.name) ? new Wrap(
                                children: <Widget>[
                                  new CircleAvatar(
                                    radius: 14.0,
                                    backgroundColor: const Color(0xFF778198),
                                    child: new Text(_entryItems[val.name].toString(),
                                      style: new TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  new Padding(
                                    padding: const EdgeInsets.only(top: 7.0),
                                    child: new Icon(Icons.arrow_forward_ios, color: Colors.black, size: 15.0),
                                  )
                                ],
                              ) : new Container(
                                alignment: Alignment.center,
                                child: new Icon(Icons.arrow_forward_ios, color: Colors.black, size: 15.0),
                              )
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
              new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                    //child: new Text(_evtParticipant.name, style: new TextStyle(fontSize: 16.0, color: Colors.black))
                    child: new Wrap(
                      children: <Widget>[
                        new Text("${_evtParticipant.name} ", style: new TextStyle(fontSize: 16.0, color: Colors.black)),
                        new Text("${StringUtil.camelize(_categoryGender)}", style: new TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.bold))
                      ],
                    ),
                  )
              ),
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
    String _categoryGender = "";

    // show tips
    if(tipsTimer == null && participant != null) {
      tipsTimer = ShowTips.showTips(context, "registration");
    }

    if(participant != null) {
      var _participant = participant["user"];
      if (_participant is User) {
        if (_participant.category == DanceCategory.PROFESSIONAL)
          _categoryGender = "PRO";
        else
          _categoryGender = "AM";

        if (_participant.gender == Gender.MAN)
          _categoryGender += " GUY";
        else
          _categoryGender += " GIRL";
      }
      else if(_participant is Couple) {
        _categoryGender = EntryFormUtil.getParticipantCodeOnUser(
            _participant, "couple").toString();
        _categoryGender = _categoryGender.replaceAll("FormParticipantCode.", "").replaceAll("_", " ");
      }
    }

    //print("_partLength: ${_participants.length}");

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
                        // logging for crashlytics
                        global.messageLogs.add("Select Participants tapped.");
                        AnalyticsUtil.sendAnalyticsEvent("select_participants_press", params: {
                          'screen': 'event_registration'
                        });
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
                                child: participant == null ? new Text("Select Participant(s)", style: new TextStyle(fontSize: 17.0, color: Colors.black)) :
                                new Wrap(
                                  children: <Widget>[
                                    new Text("${participant["name"]} ", style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                                    new Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: (participant["user"] is Couple || participant["user"] is User) ?
                                        new Text("(${StringUtil.camelize(_categoryGender)})", style: new TextStyle(fontSize: 13.0, color: Colors.black, fontWeight: FontWeight.bold)) :
                                        new Container(),
                                    )
                                  ],
                                ),
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
                // logging for crashlytics
                global.messageLogs.add("Add to Event button tapped.");
                AnalyticsUtil.sendAnalyticsEvent("add_to_event", params: {
                  'screen': 'event_registration'
                });
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
            children: _participants.map<Widget>((val){
              return _generateEntryItem(val);
            }).toList(),
          )
        ],
      ),
      /*floatingActionButton: new InkWell(
        onTap: (){
          if(_participantEntries.length > 0) {
            if(_participants.length == _participantEntries.length) {
              print(_participantEntries);
              summary.participantEntries = _participantEntries;
              summary.eventEntries = _eventEntries;
              Navigator.of(context).pushNamed("/registrationSummary");
              // deactivate tips for registration
              participant = null;
              if (tipsTimer != null)
                tipsTimer.cancel();
              tipsTimer = null;
            } else {
              // entries are not filled
              for(var _pEntries in _participants) {
                if(!_participantEntries.containsKey(_pEntries)) {
                  showMainFrameDialog(context, "Cannot Proceed", "Please select an Entry for ${_pEntries.name}.");
                  break;
                }
              }
            }
          }
          else {
            showMainFrameDialog(context, "Cannot Proceed", "Please add Participant(s) to the event with associated entries.");
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
      )*/
      bottomNavigationBar: new Container(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: new Container(
          padding: const EdgeInsets.only(left: 20.0, right: 5.0, top: 2.0, bottom: 5.0),
          height: 40.0,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                child: new Wrap(
                  children: <Widget>[
                    new InkWell(
                      onTap: (){
                        //print("participants: ${_participants.length}");
                        ticketSummary.ticketConf = eventItem.ticketConfig;
                        ticketSummary.participants = [];
                        ticketSummary.participants.addAll(_participants);

                        ticketSummary.participants.forEach((evtParticipant){
                          evtParticipant.formEntries = [];
                          _eventEntries.forEach((key, itm){
                            if(itm.participant == evtParticipant.user) {
                              // if matched user
                              //print("matched user participant: ${itm.participant.toJson()}");
                              evtParticipant.formEntries.add(itm.formEntry);
                              //print(evtParticipant.formEntries?.runtimeType);
                            }
                          });
                        });
                        Navigator.of(context).pushNamed("/ticketSummary");
                      },
                      child: new Container(
                        decoration: new BoxDecoration(
                          image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
                        ),
                        width: 115.0,
                        height: 32.0,
                        child: new Center(child: new Text("Tickets", style: new TextStyle(fontSize: 17.0))),
                      ),
                    )
                  ],
                ),
              ),
              new InkWell(
                onTap: (){
                  // logging for crashlytics
                  global.messageLogs.add("Proceed button tapped.");
                  AnalyticsUtil.sendAnalyticsEvent("proceed_btn_press", params: {
                    'screen': 'event_registration'
                  });
                  if(EntryFormUtil.isEventEntryFinalized(eventItem)) {
                    if(_participantEntries.length > 0) {
                      if(_participants.length == _participantEntries.length) {
                        print(_participantEntries);
                        summary.participantEntries = _participantEntries;
                        summary.eventEntries = _eventEntries;
                        summary.participants = _participants;
                        //Navigator.of(context).pushNamed("/registrationSummary");
                        Navigator.of(context).pushNamed("/studioDetails");
                        // deactivate tips for registration
                        participant = null;
                        if (tipsTimer != null)
                          tipsTimer.cancel();
                        tipsTimer = null;
                      } else {
                        // entries are not filled
                        for(var _pEntries in _participants) {
                          if(!_participantEntries.containsKey(_pEntries)) {
                            showMainFrameDialog(context, "Cannot Proceed", "Please select an Entry for ${_pEntries.name}.");
                            break;
                          }
                        }
                      }
                    }
                    else {
                      showMainFrameDialog(context, "Cannot Proceed", "Please add Participant(s) to the event with associated entries.");
                    }
                  } else {
                    AdminNotification.sendNotification("Event Not finalized. Please check Finance for Event.");
                    showMainFrameDialog(context, "Cannot Proceed", "Event Entries are not yet finalised. Please contact Support for details.");
                  }
                },
                child: new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
                  ),
                  width: 115.0,
                  height: 40.0,
                  child: new Center(child: new Text("Proceed", style: new TextStyle(fontSize: 17.0))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}