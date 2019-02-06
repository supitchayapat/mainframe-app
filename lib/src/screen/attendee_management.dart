import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import '../util/StringUtil.dart';
import 'package:myapp/src/util/ShowTipsUtil.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'add_dance_partner.dart' as addPartner;
import 'event_registration.dart' as registration;
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/screen/ticket_summary_a60.dart' as ticketSummary;
import 'package:myapp/src/model/Ticket.dart';

var participantUser;
var tipsTimer;
var participantType;

class attendee_management extends StatefulWidget {
  @override
  _attendee_managementState createState() => new _attendee_managementState();
}

class _attendee_managementState extends State<attendee_management> {
  List _listItems = [];
  Map<String, User> _attendees = {};
  var attendeeListener;

  @override
  void initState() {
    participantType = null;
    super.initState();

    // logging for crashlytics
    global.messageLogs.add("Attendee Management Screen.");
    AnalyticsUtil.setCurrentScreen("Attendee Management", screenClassName: "attendee_management");

    attendeesListener((users){
      setState(() {
        _attendees = {};
        _listItems = [];
        users.forEach((val){
          //_listItems.add("${val.first_name} ${val.last_name}");
          _listItems.add(val);
          _attendees.putIfAbsent("${val.first_name} ${val.last_name}", () => val);
        });
      });
    }).then((listener) {attendeeListener = listener;});
  }

  @override
  void dispose() {
    super.dispose();
    attendeeListener.cancel();
    if(tipsTimer != null)
      tipsTimer.cancel();
  }

  Widget _generateItem(val) {
    Widget _entryChild;
    String _categoryGender = "";

    if(val.category == DanceCategory.PROFESSIONAL)
      _categoryGender = "PRO";
    else
      _categoryGender = "AM";

    if(val.gender == Gender.MAN)
      _categoryGender += " GUY";
    else
      _categoryGender += " GIRL";

    _entryChild = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Expanded(
            child: new Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: new Wrap(
                children: <Widget>[
                  new Text("${val.first_name} ${val.last_name} ", style: new TextStyle(fontSize: 16.0, color: Colors.black)),
                  /*new Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: new Text("(${StringUtil.camelize(_categoryGender)})", style: new TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.bold)),
                  )*/
                ],
              )
            )
        ),
        new Container(
          //color: Colors.amber,
          width: 35.0,
          child: new IconButton(
              icon: new Icon(Icons.cancel, color: Colors.black),
              onPressed: (){
                if(_attendees.containsKey("${val.first_name} ${val.last_name}")) {
                  removeAttendee(_attendees["${val.first_name} ${val.last_name}"]);
                  _attendees.remove("${val.first_name} ${val.last_name}");
                }
              }
          ),
        )
      ],
    );

    return new InkWell(
      onTap: (){
        // existing attendee selected
        if(!ticketSummary.attendeeBucket.containsKey("${val.first_name} ${val.last_name}")) {
          /*setState((){
            registration.participant = {
              "name": "${participantUser.first_name} ${participantUser.last_name}",
              "user": participantUser
            };
            registration.tipsTimer = null;
          });*/
          setState(() {
            ticketSummary.attendees.add("${val.first_name} ${val.last_name}");
            ParticipantAttendeeTicket _ticket = new ParticipantAttendeeTicket(
                name: "${val.first_name} ${val.last_name}",
                type: "attendee",
                user: val
            );
            ticketSummary.eventTickets.add(_ticket);
            ticketSummary.dropValue = "${val.first_name} ${val.last_name}";
            participantUser = null;
            //Navigator.maybePop(context);
            participantType = null;
          });
          Navigator.of(context).popUntil(ModalRoute.withName("/ticketSummary"));
        }
        else
          showMainFrameDialog(context, "Cannot Add Attendee", "Attendee already added on the list");
      },
      child: new Container(
        decoration: new BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
        height: 55.0,
        child: _entryChild,
      ),
    );
  }

  Widget _generateInputContainer() {
    String _categoryGender = "";

    if(participantUser?.category == DanceCategory.PROFESSIONAL)
      _categoryGender = "PRO";
    else
      _categoryGender = "AM";

    if(participantUser?.gender == Gender.MAN)
      _categoryGender += " GUY";
    else
      _categoryGender += " GIRL";

    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 10.0),
            child: new Text("Tap ASSIGN to assign a new Attendee", style: new TextStyle(fontSize: 18.0)),
          ),
          new Container(
            padding: const EdgeInsets.only(top: 10.0),
            child: new Row(
              children: <Widget>[
                new Text("Attendee:", style: new TextStyle(fontSize: 17.0)),
                new Container(
                  margin: const EdgeInsets.only(left: 10.0),
                  decoration: new BoxDecoration(
                      borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                      border: new Border.all(
                        width: 2.0,
                        color: const Color(0xFF313746),
                        style: BorderStyle.solid,
                      )
                  ),
                  child: new MaterialButton(
                    padding: const EdgeInsets.all(7.0),
                    minWidth: 5.0, height: 5.0,
                    color: Colors.white,
                    onPressed: () {
                      //couple1 = "_assignCoupleParticipant";
                      // logging for crashlytics
                      global.messageLogs.add("Assign button pressed.");
                      AnalyticsUtil.sendAnalyticsEvent("assign_btn_pressed", params: {
                        'screen': 'attendee_management'
                      });
                      addPartner.tipsTimer = null;
                      participantType = "attendee";
                      Navigator.of(context).pushNamed("/addPartner");
                    },
                    child: (participantUser == null || participantUser is String) ? new Text("ASSIGN",
                      style: new TextStyle(
                          fontSize: 17.0,
                          color: Colors.black
                      ),
                    ) : new Wrap(
                      children: <Widget>[
                        new Text("${participantUser.first_name} ${participantUser.last_name} ", style: new TextStyle(fontSize: 17.0,color: Colors.black)),
                        /*new Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: new Text("(${StringUtil.camelize(_categoryGender)})", style: new TextStyle(fontSize: 12.0,color: Colors.black, fontWeight: FontWeight.bold)),
                        )*/
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          new Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 10.0, bottom: 0.0),
            child: new MainFrameButton(
              child: new Text("ADD ATTENDEE"),
              onPressed: (){
                // logging for crashlytics
                global.messageLogs.add("Add Participant button pressed.");
                AnalyticsUtil.sendAnalyticsEvent("add_participant_pressed", params: {
                  'screen': 'attendee_management'
                });
                if(participantUser != null) {
                  //if(!_listItems.contains("${participantUser.first_name} ${participantUser.last_name}"))
                  if(!_listItems.contains(participantUser)) {
                    saveAttendee(participantUser);
                    setState((){
                      ticketSummary.attendees.add("${participantUser.first_name} ${participantUser.last_name}");
                      ParticipantAttendeeTicket _ticket = new ParticipantAttendeeTicket(
                          name: "${participantUser.first_name} ${participantUser.last_name}",
                          type: "attendee",
                          user: participantUser
                      );
                      ticketSummary.eventTickets.add(_ticket);
                      ticketSummary.dropValue = "${participantUser.first_name} ${participantUser.last_name}";
                      participantUser = null;
                      //Navigator.maybePop(context);
                      participantType = null;
                    });
                    Navigator.of(context).popUntil(ModalRoute.withName("/ticketSummary"));
                  }
                  else
                    showMainFrameDialog(context, "Cannot Add Attendee", "Attendee already added on the list");
                }
                else {
                  showMainFrameDialog(context, "Unassigned Attendee", "Please tap ASSIGN to assign an Attendee.");
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _inputContainer = _generateInputContainer();
    List<Widget> _children = [];

    if(_listItems.isNotEmpty) {
      _children.add(
          new Container(
            padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
            child: new Text("Tap the name below to add an Attendee",
                style: new TextStyle(fontSize: 18.0)),
          )
      );
    }
    _children.addAll(_listItems.map<Widget>((val){
      return _generateItem(val);
    }).toList());

    //if(tipsTimer == null)
      //tipsTimer = ShowTips.showTips(context, "soloParticipant");

    return new Scaffold(
      appBar: new MFAppBar("ATTENDEE MANAGEMENT", context),
      body: new Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
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
              child: new Column(
                children: <Widget>[
                  _inputContainer
                ],
              ),
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
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 0.0),
              decoration: new BoxDecoration(
                border: const Border(
                  top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                ),
              ),
            ),
          ),
          new Flexible(
            child: new ListView(
              children: _children,
            ),
          )
        ],
      ),
    );
  }
}