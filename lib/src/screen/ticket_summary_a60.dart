import 'package:flutter/material.dart';
import 'main_drawer.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/screen/ticket_purchase.dart' as ticketPurchase;
import 'package:myapp/src/model/Ticket.dart';
import 'package:myapp/src/dao/TicketDao.dart';
import 'package:myapp/src/screen/event_registration.dart' as registration;

var ticketConf;
List<String> attendees;
List<ParticipantAttendeeTicket> eventTickets;
var participants;
var evtEntries;
final formatter = new DateFormat("MMMM dd, yyyy");
String dropValue = "SELECT ATTENDEE";
Map<String, TicketEvent> attendeeBucket;

class ticket_summary_a60 extends StatefulWidget {
  @override
  _ticket_summary_a60State createState() => new _ticket_summary_a60State();
}

class _ticket_summary_a60State extends State<ticket_summary_a60> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _handleView() {
    if(dropValue == "SUMMARY") {
      showSummaryDialog(context);
    }
    else {
      showTicketDialog(context, dropValue);
    }
  }

  @override
  void initState() {
    super.initState();
    attendees = [];
    eventTickets = [];
    attendeeBucket = {};
    dropValue = "SELECT ATTENDEE";

    if(participants != null) {
      participants.forEach((itm) {
        if (itm.user is Couple) {
          print("IS COUPLE: Adding couple participants");
          if(itm.user?.couple != null) {
            itm.user.couple.forEach((_cpl){
              addEventTicketParticipant(_cpl);
            });
          }
        }
        else if (itm.user is Group) {
          print("IS GROUP: Adding group members.");
          if(itm.user?.members != null) {
            itm.user.members.forEach((membr){
              addEventTicketParticipant(membr);
            });
          }
        } else {
          print("IS SOLO: Adding participant");
          addEventTicketParticipant(itm.user);
        }
        //print("ENTRIES: ${itm.formEntries?.length}");
      });
    }
    if(attendees != null && attendees.length > 0){
      attendees.forEach((attendee){
        ParticipantAttendeeTicket _ticket = new ParticipantAttendeeTicket(
            name: attendee,
            type: "attendee",
            user: null
        );
        eventTickets.add(_ticket);
      });
    }

    TicketDao.getEventTickets(registration.eventItem, (evtTickets){
      setState(() {
        if(evtTickets != null && evtTickets.length > 0) {
          //print("LENGTH: ${eventTickets.length}");
          //eventTickets = [];
          for(var itm in evtTickets){
            attendeeBucket.putIfAbsent(itm.attendee, () => itm);
            ParticipantAttendeeTicket _ticket = new ParticipantAttendeeTicket(
                name: itm.attendee,
                type: itm.isParticipant,
                user: null
            );
            //print("ATTENDEE: ${_ticket.toJson()}");
            if(!_isWithinEventTickets(eventTickets, _ticket)) {
              eventTickets.add(_ticket);
            }
          }
        }
        //print("LENGTH: ${eventTickets.length}");
      });
    });
  }

  void _handleBackButton() {
    Navigator.of(context).popUntil(ModalRoute.withName("/registration"));
  }

  void addEventTicketParticipant(usr) {
    ParticipantAttendeeTicket _ticket = new ParticipantAttendeeTicket(
        name: "${usr.first_name} ${usr.last_name}",
        type: "participant",
        user: usr
    );
    if(!_isWithinEventTickets(eventTickets, _ticket)) {
      eventTickets.add(_ticket);
    }
  }

  bool setSessionCodes(usr, itm) {
    bool retVal = false;
    String _name = "${usr.first_name} ${usr.last_name}";
    if(dropValue == _name) {
      ticketPurchase.isParticipant = true;
      retVal = true;
      ticketPurchase.formSessionCodes = [];
      //print("FORM ENTRY: ${itm.formEntries}");
      itm.formEntries.forEach((entry){
        //print("ENTRY SESSION CODE: ${entry.sessionCode}");
        ticketPurchase.formSessionCodes.add(entry.sessionCode);
      });
    }
    return retVal;
  }

  bool _isWithinEventTickets(eventTickets, participantAttendeeTicket) {
    bool retVal = false;
    for(var _et in eventTickets) {
      if(_et.name == participantAttendeeTicket.name) {
        retVal = true;
        break;
      }
    }
    return retVal;
  }

  void _handleBtnPress(session, date, sessionCode, {bool isDinner, int btnId}) {
    DateFormat dformatter = new DateFormat("yyyy-MM-dd");
    if(dropValue == "SELECT ATTENDEE" || dropValue == "ADD ATTENDEE ...") {
      showMainFrameDialog(context, "SELECT ATTENDEE", "Please select attendee first before adding a session ticket.");
    }
    else {
      if(session != null && session.toString().isNotEmpty && date != null && date.toString().isNotEmpty) {
        ticketPurchase.session = session;
        ticketPurchase.sessionCode = sessionCode;
        ticketPurchase.attendee = dropValue;
        DateTime dt = dformatter.parse(date);
        ticketPurchase.dayOfWeek = getDayOfWeek(dt);
        ticketPurchase.date = formatter.format(dt);
        //print("isDinner: $isDinner");
        if(isDinner == null) {
          ticketPurchase.dinnerIndicator = false;
        }
        else {
          ticketPurchase.dinnerIndicator = true;
          ticketPurchase.withDinner = isDinner;
        }

        if(btnId != null) {
          ticketPurchase.selectedTickets = _getSelectedTicketsFromBucket(dt, btnId);
          print("SELECTED TICKETS: ${ticketPurchase.selectedTickets}");
          ticketPurchase.buttonId = btnId;
        }

        // get session code if participant
        bool _isParticipant = false;
        for(var itm in participants){
          if (itm.user is Couple) {
            print("IS COUPLE: iterating couple");
            if(itm.user?.couple != null) {
              for(var _cpl in itm.user.couple) {
                if(setSessionCodes(_cpl, itm)) {
                  _isParticipant = true;
                  break;
                }
              }
            }
          }
          else if (itm.user is Group) {
            print("IS GROUP: iterating group members.");
            if(itm.user?.members != null) {
              for(var membr in itm.user.members) {
                if(setSessionCodes(membr, itm)) {
                  _isParticipant = true;
                  break;
                }
              }
            }
          } else {
            print("IS SOLO: solo participant");
            _isParticipant = setSessionCodes(itm.user, itm);
          }
        }

        if(!_isParticipant) {
          ticketPurchase.isParticipant = _isParticipant;
          ticketPurchase.formSessionCodes = [];
        }

        // go ticket purchase screen
        Navigator.pushNamed(context, "/ticketPurchase");
      }
      else {
        //print("date or session empty");
        showMainFrameDialog(context, "DATE & SESSION", "Please contact support for session and date issues.");
      }
    }
  }

  List<Widget> _generateCard(String _txtContent, String date, String sessionCode, {Color legend, bool isDay, int id}) {
    List<Widget> _expanded = [];
    var isDinner = null;

    if(_isIndicatorTrue(legend) && _isDinner(legend)) {
      isDinner = true;
    }
    if(_isIndicatorTrue(legend) && !_isDinner(legend)) {
      isDinner = false;
    }

    _expanded.add(new Container(
      decoration: new BoxDecoration(
          border: const Border(
              top: const BorderSide(width: 1.0, color: Colors.grey),
              right: const BorderSide(width: 1.0, color: Colors.grey)
          )
      ),
      //color: const Color(0xffffffff),
      child: new Container(
        color: const Color(0xffffffff),
        height: 70.0,
        width: 75.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Expanded(
                child: new Container(
                  //color: Colors.amber,
                  padding: const EdgeInsets.only(top: 15.0),
                  child: new Center(
                    child: new Container(
                      decoration: new BoxDecoration(
                          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                          border: new Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          )
                      ),
                      width: 45.0,
                      height: 45.0,
                      child: new MaterialButton(
                        padding: new EdgeInsets.all(0.0),
                        minWidth: 5.0, height: 5.0,
                        color: const Color(0xffffffff),
                        onPressed: () => _handleBtnPress((isDay != null && isDay) ? "day" : "evening", date, sessionCode, isDinner: isDinner, btnId: id),
                        child: new Text(_txtContent,
                          style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
            new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: (legend == null) ? Colors.white : legend)
          ],
        ),
      ),
    ));

    if(isDay != null && isDay) {
      _expanded.add(new Container(
        height: 70.0,
        width: 75.0,
        //color: Colors.cyanAccent,
      ));
    }

    return _expanded;
  }

  Widget _generateExpandedCard(String _txtContent, String date, String sessionCode, {Color legend, int id}) {
    Widget _expanded;
    var isDinner = null;

    if(_isIndicatorTrue(legend) && _isDinner(legend)) {
      isDinner = true;
    }
    if(_isIndicatorTrue(legend) && !_isDinner(legend)) {
      isDinner = false;
    }

    _expanded = new Container(
      decoration: new BoxDecoration(
          border: const Border(
              top: const BorderSide(width: 1.0, color: Colors.grey)
          )
      ),
      //color: const Color(0xffffffff),
      child: new Container(
        color: const Color(0xffffffff),
        height: 70.0,
        width: 151.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Expanded(
                child: new Container(
                  //color: Colors.amber,
                  padding: const EdgeInsets.only(top: 15.0),
                  child: new Center(
                    child: new Container(
                      decoration: new BoxDecoration(
                          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                          border: new Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          )
                      ),
                      width: 45.0,
                      height: 45.0,
                      child: new MaterialButton(
                        padding: new EdgeInsets.all(0.0),
                        minWidth: 5.0, height: 5.0,
                        color: const Color(0xffffffff),
                        onPressed: () => _handleBtnPress("wholeday", date, sessionCode, isDinner: isDinner, btnId: id),
                        child: new Text(_txtContent,
                          style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
            new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: (legend == null) ? Colors.white : legend)
          ],
        ),
      ),
    );

    return _expanded;
  }

  List<Widget> _generateTwoCards(List<String> _numbers, String date, List<String> _sessionCodes, {List<Color> legends, List<int> ids}) {
    List<Widget> _cards = [];

    List<bool> isDinner = [];

    legends.forEach((legend){
      if(_isIndicatorTrue(legend) && _isDinner(legend)) {
        isDinner.add(true);
      }
      else if(_isIndicatorTrue(legend) && !_isDinner(legend)) {
        isDinner.add(false);
      }
      else if(!_isIndicatorTrue(legend)) {
        isDinner.add(null);
      }
    });

    _cards.add(new Container(
      decoration: new BoxDecoration(
          border: const Border(
              right: const BorderSide(width: 1.0, color: Colors.grey)
          )
      ),
      //color: const Color(0xffffffff),
      child: new Container(
        color: const Color(0xffffffff),
        height: 70.0,
        width: 75.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Expanded(
                child: new Container(
                  //color: Colors.amber,
                  padding: const EdgeInsets.only(top: 15.0),
                  child: new Center(
                    child: new Container(
                      decoration: new BoxDecoration(
                          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                          border: new Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          )
                      ),
                      width: 45.0,
                      height: 45.0,
                      child: new MaterialButton(
                        padding: new EdgeInsets.all(0.0),
                        minWidth: 5.0, height: 5.0,
                        color: const Color(0xffffffff),
                        onPressed: () => _handleBtnPress("day", date.toString(), _sessionCodes[0], isDinner: isDinner[0], btnId: ids[0]),
                        child: new Text(_numbers[0],
                          style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
            new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: (legends.isEmpty) ? Colors.white : legends[0])
          ],
        ),
      ),
    ));

    // 2nd card
    _cards.add(new Container(
      color: const Color(0xffffffff),
      height: 70.0,
      width: 75.0,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Expanded(
              child: new Container(
                //color: Colors.amber,
                padding: const EdgeInsets.only(top: 15.0),
                child: new Center(
                  child: new Container(
                    decoration: new BoxDecoration(
                      borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                      border: new Border.all(
                        color: Colors.black,
                        style: BorderStyle.solid,
                      )
                    ),
                    width: 45.0,
                    height: 45.0,
                    child: new MaterialButton(
                      padding: new EdgeInsets.all(0.0),
                      minWidth: 5.0, height: 5.0,
                      color: const Color(0xffffffff),
                      onPressed: () => _handleBtnPress("evening", date.toString(), _sessionCodes[1], isDinner: isDinner[1], btnId: ids[1]),
                      child: new Text(_numbers[1],
                        style: new TextStyle(
                            fontSize: 18.0,
                            color: Colors.black
                        ),
                      ),
                    ),
                  ),
                ),
              )
          ),
          new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: (legends.isEmpty) ? Colors.white : legends[1])
        ],
      ),
    ));

    return _cards;
  }

  String getDayOfWeek(dt) {
    int _dow = dt.weekday; // day of week int
    String retVal = "DAY";
    switch(_dow) {
      case 1:
        retVal = "MONDAY";
        break;
      case 2:
        retVal = "TUESDAY";
        break;
      case 3:
        retVal = "WEDNESDAY";
        break;
      case 4:
        retVal = "THURSDAY";
        break;
      case 5:
        retVal = "FRIDAY";
        break;
      case 6:
        retVal = "SATURDAY";
        break;
      case 7:
        retVal = "SUNDAY";
        break;
      default:
        retVal = "DAY";
        break;
    }
    return retVal;
  }

  bool _isDinner(Color c) {
    if(c == Color(0xFF4AD778)) {
      return true;
    }
    else {
      return false;
    }
  }

  bool _isIndicatorTrue(Color c) {
    if(c != Colors.white) {
      return true;
    }
    else {
      return false;
    }
  }

  Color _getDinner(ticketType) {
    Color retVal;
    if(ticketType.dinner_indicator == false) {
      retVal = Colors.white;
    } else if(ticketType.dinner_indicator && ticketType.dinner_included) {
      retVal = const Color(0xFF4AD778);
    } else if(ticketType.dinner_indicator && ticketType.dinner_included == false) {
      retVal = const Color(0xFFFD7333);
    }
    return retVal;
  }

  int _getCountFromAttendeeBucket(date, itmID) {
    int retVal = 0;
    if(attendeeBucket != null && !attendeeBucket.isEmpty && dropValue != "SELECT ATTENDEE") {
      if(attendeeBucket.containsKey(dropValue)) {
        attendeeBucket[dropValue]?.attendee_tickets.forEach((attTicket){
          //print("DATE: ${attTicket.ticket_date} === ${date}  [[${attTicket.ticket_date.isAtSameMomentAs(date)}]]");
          //print("BUTN ID: ${attTicket.button_id} == ITM ID ${itm.id}");
          if(date == attTicket.ticket_date && itmID == attTicket.button_id) {
            retVal = attTicket.total_tickets;
          }
        });
      }
    }
    return retVal;
  }

  List<TicketSelected> _getSelectedTicketsFromBucket(date, itmID) {
    List<TicketSelected> retVal = [];
    if(attendeeBucket != null && !attendeeBucket.isEmpty && dropValue != "SELECT ATTENDEE") {
      if(attendeeBucket.containsKey(dropValue)) {
        attendeeBucket[dropValue]?.attendee_tickets.forEach((attTicket){
          //print("DATE: ${attTicket.ticket_date} === ${date}  [[${attTicket.ticket_date.isAtSameMomentAs(date)}]]");
          //print("BUTN ID: ${attTicket.button_id} == ITM ID ${itmID}");
          if(date == attTicket.ticket_date && itmID == attTicket.button_id) {
            retVal = attTicket.tickets_selected;
            //print("ATT TICKETS: ${attTicket.tickets_selected}");
            /*attTicket.tickets_selected.forEach((_i){
              print(_i.toJson());
            });*/
          }
        });
      }
    }
    //print("LENGTH: ${retVal.length}");
    return retVal;
  }

  Widget rowContentGenerate(rowItem, date) {
    List<Widget> retVal = [];
    //print("row generate!");

    if(rowItem?.types != null && rowItem.types.length > 1) {
      // more than one column
      //print("MORE THAN 1 TYPE");
      List<Color> _dinnerLegends = [];
      List<String> _sessionCodes = [];
      List<String> _counts = [];
      List<int> _ids = [];
      rowItem.types.forEach((itm){
        _dinnerLegends.add(_getDinner(itm));
        _sessionCodes.add(itm.session);
        int _cnt = _getCountFromAttendeeBucket(date, itm.id);
        _ids.add(itm.id);
        if(_cnt > 0) {
          _counts.add(_cnt.toString());
        } else {
          _counts.add("0");
        }
      });
      retVal = _generateTwoCards((_counts.isEmpty) ? ["0", "0"] : _counts, date.toString(), _sessionCodes, legends: _dinnerLegends, ids: _ids);
    } else if(rowItem?.types != null && rowItem.types.length > 0) {
      // either wholeday, day or night
      //print("SINGLE TYPE");
      rowItem.types.forEach((itm){
        int _cnt = _getCountFromAttendeeBucket(date, itm.id);
        if(itm?.type != null && itm.type == "wholeday") {
          //print("WHOLE DAY");
          retVal.add(_generateExpandedCard((_cnt > 0) ? _cnt.toString() : "0", date.toString(), itm.session, legend: _getDinner(itm), id: itm.id));
        }
        else if(itm?.type != null && itm.type == "day") {
          //print("DAY");
          retVal = _generateCard((_cnt > 0) ? _cnt.toString() : "0", date.toString(), itm.session, legend: _getDinner(itm), isDay: true, id: itm.id);
        }
        else if(itm?.type != null && itm.type == "evening") {
          //print("NIGHT");
          retVal = _generateCard((_cnt > 0) ? _cnt.toString() : "0", date.toString(), itm.session, legend: _getDinner(itm), isDay: false, id: itm.id);
        }
      });
    }

    return new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: retVal,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> _attendees = [];
    List<String> _columnHeaders = [];
    List<Widget> _dateChildren = [];

    _attendees.add("SELECT ATTENDEE");
    eventTickets?.forEach((itm){
      //print("eventickets name: ${itm.name}");
      _attendees.add(itm.name);
    });
    _attendees.add("ADD ATTENDEE ...");
    ticketConf?.columns.forEach((itm) {
      _columnHeaders.add(itm.header);
    });
    ticketConf?.dates?.forEach((itm){
      //print(getDayOfWeek(itm.date));
      List<Widget> _childRows = [];
      itm?.rows?.forEach((childItem){
        //print("childItem");
        _childRows.add(rowContentGenerate(childItem ,itm.date));
      });
      //print("childrows [${_childRows.length}]");

      _dateChildren.add(
          new Container(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            decoration: new BoxDecoration(
              border: const Border(
                top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                //bottom: const BorderSide(width: 1.0, color: Colors.white)
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
              child: new Row(
                children: <Widget>[
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(getDayOfWeek(itm.date), style: const TextStyle(fontSize: 18.0)),
                      new Text(formatter.format(itm.date), style: const TextStyle(fontSize: 14.0, color: const Color(0xFF6482BF)))
                    ],
                  ),
                  new Expanded(
                      child: new Container(
                        padding: const EdgeInsets.only(right: 10.0),
                        //color: Colors.amber,
                        child: new Container(
                          //color: Colors.amber,
                          child: (_childRows.length > 1) ? new Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _childRows,
                          ) : new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            //children: _generateTwoCards(["0", "0"], legends: [Colors.white, const Color(0xFF4AD778)]),
                            children: _childRows,
                          ),
                        )
                      )
                  )
                ],
              ),
            ),
          )
      );
    });
    _dateChildren.add(
      // Legend
      new Container(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        decoration: new BoxDecoration(
          border: const Border(
            top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
            //bottom: const BorderSide(width: 1.0, color: Colors.white)
          ),
        ),
        child: new Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
          decoration: new BoxDecoration(
            border: const Border(
              top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
              //bottom: const BorderSide(width: 1.0, color: Colors.white)
            ),
          ),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text("LEGEND", style: const TextStyle(fontSize: 18.0, color: const Color(0xFF6482BF))),
              new Padding(padding: const EdgeInsets.only(right: 10.0)),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: const Color(0xFF4AD778)),
                      new Padding(padding: const EdgeInsets.only(right: 5.0)),
                      new Text("Dinner Included"),
                    ],
                  ),
                  new Padding(padding: const EdgeInsets.only(top: 10.0)),
                  new Row(
                    children: <Widget>[
                      new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: const Color(0xFFFD7333)),
                      new Padding(padding: const EdgeInsets.only(right: 5.0)),
                      new Text("No Dinner Included"),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      )
    );

    return new Scaffold(
      /*appBar: new AppBar(
        title: new Text(
          "Tickets - SUMMARY",
          style: new TextStyle(
              fontFamily: "Montserrat-Light",
              fontSize: 17.0,
              fontWeight: FontWeight.w100
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          new PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                  value: "",
                  child: const Text('Buy ticket(s)')
              ),
              const PopupMenuItem<String>(
                  value: "",
                  child: const Text('Clear')
              ),
            ],
          )
        ],
      ),*/
      appBar: new MFAppBar("Tickets - SUMMARY", context, backButtonFunc: _handleBackButton),
      body: new DropdownButtonHideUnderline(
          child: new Column(
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
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                  decoration: new BoxDecoration(
                    border: const Border(
                        top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                        //bottom: const BorderSide(width: 1.0, color: Colors.white)
                    ),
                  ),
                  child: new Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          /*new Container(
                            decoration: new BoxDecoration(
                                border: new Border(
                                    right: const BorderSide(color: const Color(0xFFD5D4D9))
                                )
                            ),
                            width: 100.0,
                            height: 48.0,
                            child: new MaterialButton(
                              padding: new EdgeInsets.all(0.0),
                              minWidth: 5.0, height: 5.0,
                              color: const Color(0xFFF4EEF6),
                              onPressed: _handleView,
                              child: new Text("VIEW",
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    color: const Color(0xFF287399)
                                ),
                              ),
                            ),
                          ),*/
                          new Expanded(
                              child: new Theme(
                                  data: new ThemeData(
                                      brightness: Brightness.light
                                  ),
                                  child: new Container(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      color: Colors.white,
                                      child: new DropdownButton(
                                          iconSize: 30.0,
                                          value: dropValue,
                                          items: _attendees.map((String value) {
                                            return new DropdownMenuItem<String>(
                                                value: value,
                                                child: new Text(value));
                                          }).toList(),
                                          onChanged: (val){
                                            setState(() {
                                              eventTickets;
                                              if (val != null)
                                                dropValue = val;
                                              if(dropValue == "ADD ATTENDEE ...") {
                                                print("add attendee selected");
                                                Navigator.pushNamed(context, "/attendeeManagement");
                                              }
                                            });
                                          }
                                      )
                                  )
                              )
                          )
                        ],
                      ),
                      new Padding(padding: const EdgeInsets.only(top: 20.0)),
                      new Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            new Container(
                              //color: Colors.amber,
                              width: 151.0,
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: _columnHeaders.map((colHeader){
                                  return new Container(
                                    child: new Text(colHeader, style: new TextStyle(fontSize: 18.0)),
                                  );
                                }).toList(),
                              )
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                ),
              ),
              new Flexible(
                  child: new ListView(
                    children: _dateChildren,
                  )
              )
            ],
          )
      ),
      //drawer: new MainFrameDrawer(_scaffoldKey),
    );
  }
}