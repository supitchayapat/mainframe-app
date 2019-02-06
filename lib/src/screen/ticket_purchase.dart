import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'ticket_summary_a60.dart' as ticketSummary;
import 'package:myapp/src/model/Ticket.dart';
import 'package:myapp/src/dao/TicketDao.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/screen/event_registration.dart' as registration;

class ticket_purchase extends StatefulWidget {
  @override
  _ticket_purchaseState createState() => new _ticket_purchaseState();
}

var attendee;
var date;
var dayOfWeek;
var session;
var formSessionCodes;
var sessionCode;
var withDinner;
var dinnerIndicator;
var isParticipant;
var selectedTickets;
var buttonId;

class _ticket_purchaseState extends State<ticket_purchase> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String headingTitle = "Tickets - SUMMARY";
  Map<String, int> _ticketCount = {};
  int _totalCount = 0;
  double _sessionTotal = 0.00;
  int _competitorTicketCounter = 0;

  List<Widget> _generateTicketTypes() {
    List<Widget> _children = [];

    if(isParticipant != null && isParticipant && formSessionCodes.contains(sessionCode)) {
      _children.add(
          new Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
            child: new Text("${(attendee != null && attendee.toString().isNotEmpty) ? attendee : "Attendee"} has existing dance entries on this session. an admission ticket is required:",
              textAlign: TextAlign.justify,
              style: new TextStyle(color: Colors.black),
            ),
          )
      );
    }


    if(ticketSummary.ticketConf?.tickets != null) {
      ticketSummary.ticketConf.tickets.forEach((ticket){
        if(_isTicketShown(ticket)) {
          _children.add(
              new Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  //color: Colors.amber,
                  child: new Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[

                      new Container(
                        decoration: new BoxDecoration(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(4.0)),
                            border: new Border.all(
                              width: 2.0,
                              color: const Color(0xFF313746),
                              style: BorderStyle.solid,
                            )
                        ),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new MaterialButton(
                              padding: const EdgeInsets.all(0.0),
                              minWidth: 2.0,
                              height: 5.0,
                              color: const Color(0xFFC5CDDF),
                              onPressed: () => _handleRemoveBtn(ticket.content, ticket.amount, isCompetitorTicket: ticket.competitor_ticket),
                              child: new Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 2.0),
                                child: new Icon(Icons.remove, size: 18.0),
                              ),
                            ),
                            new MaterialButton(
                              padding: const EdgeInsets.all(0.0),
                              minWidth: 2.0,
                              height: 5.0,
                              color: Colors.white,
                              onPressed: () => _handleAddBtn(ticket.content, ticket.amount, isCompetitorTicket: ticket.competitor_ticket),
                              child: new Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 2.0),
                                child: new Icon(Icons.add, size: 18.0),
                              ),
                            ),
                          ],
                        ),
                      ),

                      new Container(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        constraints: new BoxConstraints(minWidth: 30.0),
                        alignment: Alignment.centerRight,
                        child: new Text(
                            (_ticketCount[ticket.content] != null && _ticketCount[ticket.content] != 0) ? "${_ticketCount[ticket.content]}" : " ", style: new TextStyle(color: Colors.black)),
                      ),
                      
                      new Expanded(
                          child: new Container(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: new Text(ticket.content, style: new TextStyle(
                                fontSize: 14.0, color: const Color(0xff00b2cc))),
                          ),
                      ),
                      new Expanded(
                          child: new Container(
                            //color: Colors.cyan,
                            alignment: Alignment.centerRight,
                            child: new Text("\$${ticket.amount.toStringAsFixed(2)}",
                                style: new TextStyle(color: Colors.black)),
                          )
                      )
                    ],
                  )
              )
          );
        }
      });
    }

    _children.add(
      new Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: new Divider(color: Colors.black, height: 16.0)
      )
    );

    return _children;
  }

  bool _isTicketShown(ticket) {
    bool _showTicket = false;
    if(ticket.session != null && ticket.session.contains(",")) {
      // multiple session codes
      List<String> _sessionCodes = ticket.session.split(",");
      if(_sessionCodes.contains(sessionCode)) {
        _showTicket = true;
      }
    } else if(ticket.session != null && ticket.session == sessionCode) {
      _showTicket = true;
    }

    if(session != null && session == "evening") {
      if (ticket.dinner_included != withDinner) {
        _showTicket = false;
      }
    }

    if(isParticipant != null && isParticipant) {
      if (formSessionCodes.contains(sessionCode)) {
        //print("TICKET SESSION CODE: $sessionCode");
        //print(ticket.content);
        //print("COMPETITOR TICKET: ${ticket.competitor_ticket}");
        //print("COMPETITOR TICKET COUNTER: $_competitorTicketCounter");
      }
      else {
        if (ticket.competitor_ticket) {
          //print("TICKET HIDDEN: ${ticket.content}");
          _showTicket = false;
        }
      }
    }
    else if(ticket.competitor_ticket) {
      _showTicket = false;
    }

    return _showTicket;
  }

  void _handleAddBtn(ticketIdx, price, {bool isCompetitorTicket}) {
    int _count = 0;
    //print("IS COMPETITOR TICKET: $isCompetitorTicket");
    //print("counter: $_competitorTicketCounter");
    if((isCompetitorTicket && _competitorTicketCounter == 0) || !isCompetitorTicket) {
      if(_ticketCount[ticketIdx] != null) {
        setState(() {
          _count = _ticketCount[ticketIdx];
          _ticketCount[ticketIdx] = _count + 1;
          _totalCount = _totalCount + 1;
          if(isCompetitorTicket)
            _competitorTicketCounter += 1;
          _sessionTotal = _sessionTotal + price;
        });
      }
    }
  }

  void _handleRemoveBtn(ticketIdx, price, {bool isCompetitorTicket}) {
    int _count = 0;
    if(_ticketCount[ticketIdx] != null) {
      setState(() {
        _count = _ticketCount[ticketIdx];
        if((_count - 1) >= 0) {
          _ticketCount[ticketIdx] = _count - 1;
          _totalCount = _totalCount - 1;
          _sessionTotal = _sessionTotal - price;
        }
        if(isCompetitorTicket && _competitorTicketCounter > 0) {
          _competitorTicketCounter -= 1;
        }
      });
    }
  }

  void _handleOKBtn() {
    if(isParticipant != null && isParticipant && formSessionCodes.contains(sessionCode) && _competitorTicketCounter < 1) {
      showMainFrameDialog(context, "COMPETITOR ADMISSION", "Admission Ticket for the competitor is required.");
    } else if(_totalCount < 1) {
      showMainFrameDialog(context, "NO TICKET ADDED", "You need to press the '+' sign button to add tickets for this session.");
    } else {
      // checking if attendee has existing tickets
      List<TicketSelected> _selectedTickets = [];
      DateFormat dformatter = new DateFormat("MMMM dd, yyyy");
      DateTime _dt = dformatter.parse(date);

      if(ticketSummary.ticketConf?.tickets != null) {
        for(var ticket in ticketSummary.ticketConf.tickets) {
          if (_isTicketShown(ticket)) {
            print("TICKET: ${ticket.content}");
            print("COUNT: ${_ticketCount[ticket.content]}");
            print("Amount total: ${ticket.amount * _ticketCount[ticket.content]}");
            TicketSelected _selected = new TicketSelected(
              id: ticket.id,
              amount_total: ticket.amount * _ticketCount[ticket.content],
              content: ticket.content,
              count: _ticketCount[ticket.content],
              ticket_amount: ticket.amount
            );
            print("_selected: ${_selected.toJson()}");
            if(_selected.count > 0) {
              _selectedTickets.add(_selected);
            }
          }
        }

        if(ticketSummary.attendeeBucket[attendee] != null &&
            ticketSummary.attendeeBucket[attendee].attendee_tickets.isNotEmpty) {
          bool _isFound = false;
          setState(() {
            for(var _attendeeTicket in ticketSummary.attendeeBucket[attendee].attendee_tickets){
              print("attendeeTicket: ${_attendeeTicket.toJson()}");
              if(_attendeeTicket.ticket_date == _dt && _attendeeTicket.button_id == buttonId) {
                print("OBJECT FOUND");
                _isFound = true;
                // replace selected tickets with the new one
                _attendeeTicket.tickets_selected = _selectedTickets;
                _attendeeTicket.total_tickets = _totalCount;
                print(_attendeeTicket.toJson());
              }
            }

            print("ATTENDEE PUSHID: ${ticketSummary.attendeeBucket[attendee].pushId}");

            if(!_isFound) {
              print("OBJECT NOT FOUND -- add new object");
              setState(() {
                AttendeeTicket _attendeeTicket = new AttendeeTicket(
                    button_id: buttonId,
                    dinner: withDinner,
                    ticket_date: _dt,
                    type: session,
                    total_tickets: _totalCount,
                    tickets_selected: _selectedTickets
                );
                print(_attendeeTicket.toJson());
                ticketSummary.attendeeBucket[attendee].attendee_tickets.add(_attendeeTicket);
              });
            }

            // save to RTDB
            TicketDao.saveEventTickets(registration.eventItem, ticketSummary.attendeeBucket[attendee]);
          });
        } else if(ticketSummary.attendeeBucket[attendee] == null) {
          setState(() {
            // attendee not found on the bucket
            // create attendee ticket object for saving in RTDB
            TicketEvent _eTicket = new TicketEvent(attendee: attendee, isParticipant: isParticipant);
            AttendeeTicket _attendeeTicket = new AttendeeTicket(
                button_id: buttonId,
                dinner: withDinner,
                ticket_date: _dt,
                type: session,
                total_tickets: _totalCount,
                tickets_selected: _selectedTickets
            );
            print(_attendeeTicket.toJson());
            _eTicket.attendee_tickets = [];
            _eTicket.attendee_tickets.add(_attendeeTicket);
            ticketSummary.attendeeBucket.putIfAbsent(attendee, () => _eTicket);

            // save to RTDB
            TicketDao.saveEventTickets(registration.eventItem, ticketSummary.attendeeBucket[attendee]);
          });
        }
      }

      Navigator.pop(context, "OK");
    }
  }

  @override
  void initState() {
    super.initState();
    _totalCount = 0;
    _competitorTicketCounter = 0;
    _ticketCount = {};
    _sessionTotal = 0.00;

    // iterate tickets and save in the map
    if(ticketSummary.ticketConf?.tickets != null) {
      ticketSummary.ticketConf.tickets.forEach((ticket){
        if(_isTicketShown(ticket)) {
          //print("TICKET: ${ticket.content}");
          var _countTicket = _getCountTicket(ticket);
          //print("COUNT: $_countTicket");
          _ticketCount.putIfAbsent(ticket.content, () => _countTicket);
          if(ticket.competitor_ticket && _countTicket > 0) {
            _competitorTicketCounter = _countTicket;
          }
          if(_countTicket > 0) {
            _totalCount += _countTicket;
            _sessionTotal += _countTicket * ticket.amount;
          }
        }
      });
    }
  }

  int _getCountTicket(ticket) {
    int retVal = 0;
    if(selectedTickets != null) {
      for(var itm in selectedTickets){
        //print("TICKID: ${ticket.id} === ${itm.id}");
        //print("TICKET: ${itm.content}");
        //print("COUNT: ${itm.count}");
        if(itm.id == ticket.id) {
          retVal = itm.count;
        }
      }
    }
    //print("RETVAL: ${retVal}");
    return retVal;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double _height = mediaQuery.size.height;
    double _formHeight = _height - 140.0;
    String _imgAsset = "mainframe_assets/images/add_via_email.png";

    List<Widget> _sessionImgs = [];

    if(session != null && (session == "day" || session == "wholeday")) {
      _sessionImgs.add(new Image.asset("mainframe_assets/images/sun_a60.jpg",
        width: 16.0,
        height: 16.0,
      ));
    }
    if(session != null && (session == "evening" || session == "wholeday")) {
      _sessionImgs.add(new Container(
        padding: new EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
        child: new Image.asset("mainframe_assets/images/moon_a60.png",
          width: 16.0,
          height: 16.0,
        ),
      ));
    }
    // put dinner icon if indicator says so
    if(dinnerIndicator != null && dinnerIndicator && withDinner != null && withDinner) {
      _sessionImgs.add(new Container(
        padding: new EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
        child: new Image.asset("mainframe_assets/images/food_a60.png",
          width: 16.0,
          height: 16.0,
        ),
      ));
    }


    return new Scaffold(
        key: _scaffoldKey,
        appBar: new MFAppBar(headingTitle, context),
        body: new Theme(
          // Dialog Theme
          data: new ThemeData(
            brightness: Brightness.light,
          ),
          // body
          child: new Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
              color: Colors.white,
            ),
            //height: (MediaQuery.of(context).orientation == Orientation.portrait) ? 466.0 : 300.0,
            //width: 340.0,
            child: new Column(
              children: <Widget>[
                new Text((attendee != null && attendee.toString().isNotEmpty) ? attendee : "ATTENDEE NAME",
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      height: 1.5,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff000a12,
                      )
                  ),
                ),

                new Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Divider(color: Colors.black, height: 16.0)
                ),

                new Container(
                  //color: Colors.amber,
                  child: new Row(
                    children: <Widget>[
                      new Container(
                        //color: Colors.cyan,
                        //width: (MediaQuery.of(context).orientation == Orientation.portrait) ? _scrWidth * 0.6 : 340.0 * 0.8,
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new Container(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text(
                                    (dayOfWeek != null && dayOfWeek.toString().isNotEmpty) ? dayOfWeek : "DAY",
                                    style: new TextStyle(
                                      fontSize: 16.0,
                                      color: const Color(
                                        (0xff000a12),
                                      ),
                                    ),
                                  ),
                                  new Text(
                                    (date != null && !date.toString().isEmpty) ? date : "July 21, 2017",
                                    style: new TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(
                                        (0xff000a12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            new Padding(padding: const EdgeInsets.only(left: 10.0)),
                            new Container(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text((session != null && !session.toString().isEmpty) ? session.toString().toUpperCase() : "SESSION",
                                    style: new TextStyle(
                                      fontSize: 16.0,
                                      color: const Color(
                                        (0xff000a12),
                                      ),
                                    ),
                                  ),
                                  (dinnerIndicator != null && dinnerIndicator) ? new Text(
                                    (withDinner != null && withDinner) ? "with dinner" : "without dinner",
                                    style: new TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(
                                        (0xff000a12),
                                      ),
                                    ),
                                  ) : new Text(""),
                                ],
                              ),
                            ),
                            new Padding(padding: const EdgeInsets.only(left: 5.0)),
                            new Container(
                              child: new Row(
                                children: _sessionImgs
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Expanded(
                        //padding: const EdgeInsets.all(5.0),
                        child: new Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          decoration: new BoxDecoration(
                            borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                            border: new Border.all(
                              width: 2.0,
                              color: const Color(0xFF313746),
                              style: BorderStyle.solid,
                            ),
                            //color: Colors.green
                          ),
                          height: 40.0,
                          //color: Colors.green,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text("Total", style: new TextStyle(color: const Color(0xFF778198))),
                              new Text("${_totalCount}", style: new TextStyle(color: const Color(0xFF313746), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                new Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Divider(color: Colors.black, height: 16.0)
                ),

                new Flexible(
                    child: new ListView(
                      children: <Widget>[
                        new Container(
                          //color: Colors.amber,
                          //height: _formHeight,
                          child: new Column(
                            children: _generateTicketTypes(),
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
          )
        ),
        bottomNavigationBar: new Container(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          decoration: new BoxDecoration(
            border: const Border(
              top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
            ),
          ),
          child: new Container(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
            decoration: new BoxDecoration(
              border: const Border(
                top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
              ),
            ),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Expanded(
                  child: new Text("Session Total - \$${_sessionTotal.toStringAsFixed(2)}", style: new TextStyle(fontSize: 17.0)),
                ),
                new Container(
                  //width: 112.0,
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  decoration: new BoxDecoration(
                      borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                      border: new Border.all(
                        width: 2.0,
                        color: const Color(0xFF313746),
                        style: BorderStyle.solid,
                      )
                  ),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new MaterialButton(
                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                        minWidth: 2.0, height: 5.0,
                        color: const Color(0xFFC5CDDF),
                        onPressed: (){
                          Navigator.pop(context, "CANCEL");
                        },
                        child: new Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                          child: new Text("CANCEL", style: new TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      new MaterialButton(
                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                        minWidth: 35.0, height: 5.0,
                        color: Colors.white,
                        onPressed: _handleOKBtn,
                        child: new Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 2.0),
                          child: new Text("OK", style: new TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}