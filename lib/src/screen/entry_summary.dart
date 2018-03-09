import 'package:flutter/material.dart';
import 'dart:async';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/EntryFormUtil.dart';
import 'package:myapp/src/screen/checkout_entry.dart' as checkout;
import 'package:myapp/src/screen/event_registration.dart' as reg;
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/model/User.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/src/dao/TicketDao.dart';

var participantEntries;
var eventEntries;
Map participantTickets;
Map<String, Map<String, double>> entryForms = {};

class entry_summary extends StatefulWidget {
  @override
  _entry_summaryState createState() => new _entry_summaryState();
}

class _entry_summaryState extends State<entry_summary> {
  List admissionTickets = [];
  double _total = 0.0;
  /*Map<String, Map<String, double>> _entryForms = {
    'Showdance Solo': 100.0,
    'Future Celebrities Competition Kids': 20.0,
    'Group Dance Competition': 90.0,
    'Adult Showcase Single Dance': 25.0,
    'Amateur Competition': 25.0,
    'Adult Multi-Dance Competition': 100.0,
  };*/

  @override
  void initState() {
    super.initState();

    TicketDao.getTickets(reg.eventItem.id, (_evtTickets){
      if(_evtTickets != null && _evtTickets.length > 0) {
        Map _ticketUsers = {};
        _evtTickets.forEach((_pushId, _evtTicket){
          if(_evtTicket.ticketOwner != null)
            _ticketUsers.putIfAbsent(_evtTicket.ticketOwner, () => _evtTicket.ticket);
        });

        if(participantEntries != null) {
          participantTickets = {};
          participantEntries.forEach((_participant, val) {
              _populateParticipantTickets(_participant, _ticketUsers);
          });
        }
      }

      /*print("TICKETS: ");
      participantTickets.forEach((key, val){
        print(key?.toJson());
      });*/
    });

    entryForms = {};
    if(reg.eventItem.formEntries != null) {
      var _formEntries = reg.eventItem.formEntries;
      var _admission = reg.eventItem.admission;
      _formEntries.forEach((_entry){
        Map<String, double> _priceMap = {};
        _entry.participants.forEach((_p){
          //print("${_entry.formName} ${_p.code} getPrice: ${_entry.getPriceFromList(_p.price).toJson()}");
          _priceMap.putIfAbsent(_p.code, () => _entry.getPriceFromList(_p.price));
        });
        //print("pricemap: $_priceMap");
        entryForms.putIfAbsent(_entry.name, () => _priceMap);
      });
      if(_admission?.tickets != null && _admission.tickets.length > 0) {
        admissionTickets = [];
        admissionTickets.addAll(_admission.tickets);
        //admissionTickets.forEach((val) => print(val.toJson()));
      }
    }

    if(participantEntries != null) {
      participantTickets = {};
      participantEntries.forEach((_participant, val) {
        _populateParticipantTickets(_participant, null);
      });
      //print(participantTickets);
    }
    //print(_entryForms.length);
    //print(_entryForms);
  }

  void _populateParticipantTickets(_participant, ticketMap) {
    if(_participant.user is Couple) {
      Map _couple = {};
      var ticketCouple1 = ticketMap != null ? ticketMap[_participant.user.couple[0]] : null;
      var ticketCouple2 = ticketMap != null ? ticketMap[_participant.user.couple[1]] : null;
      _couple.putIfAbsent(_participant.user.couple[0], () => (ticketCouple1 != null ? ticketCouple1 : admissionTickets[0]));
      _couple.putIfAbsent(_participant.user.couple[1], () => (ticketCouple2 != null ? ticketCouple2 : admissionTickets[0]));
      if(participantTickets.containsKey(_participant))
        participantTickets[_participant] = _couple;
      else
        participantTickets.putIfAbsent(_participant, () => _couple);
    }
    else if(_participant.user is Group) {
      Map _members = {};
      for(var _member in _participant.user.members) {
        var memberTicket = ticketMap != null ? ticketMap[_member] : null;
        _members.putIfAbsent(_member, () => (memberTicket != null ? memberTicket : admissionTickets[0]));
      }
      if(participantTickets.containsKey(_participant))
        participantTickets[_participant] = _members;
      else
        participantTickets.putIfAbsent(_participant, () => _members);
    } else {
      //print("participant: ${_participant?.user?.toJson()}");
      var participantTicket = ticketMap != null ? ticketMap[_participant.user] : null;
      //print("participantTicket: ${participantTicket?.toJson()}");
      if(participantTickets.containsKey(_participant))
        participantTickets[_participant] = (participantTicket != null ? participantTicket : admissionTickets[0]);
      else
        participantTickets.putIfAbsent(_participant, () => (participantTicket != null ? participantTicket : admissionTickets[0]));
      //print("THE TICKET: ${participantTickets[_participant]?.toJson()}");
    }
  }

  Widget generateContentItem(eventParticipant, Map entries){
    //print("key: $eventParticipant");
    //print(entries);
    List<Widget> _children = [];
    entries.forEach((key, val){
      double _price = EntryFormUtil.getPriceFromForm(entryForms[key], eventParticipant.user, eventParticipant.type);
      //print("val = $val");
      var _numEntries = 0;
      //print(eventEntries);
      bool isPaidFee = false;
      for(var _entry in eventEntries.values) {
        if(_entry?.formEntry?.name == key) {
          if(_entry?.paidEntries != null && _entry?.paidEntries > 0) {
            _numEntries = val - _entry.paidEntries;
            if(val == _entry.paidEntries)
              isPaidFee = true;
          }
        }
      }
      //print("$key : $val == numEntries: $_numEntries");
      //print("price from form: \$${_price}");
      if(_price * _numEntries <= 0.0) {
        //print("numentries == 0");
        _price = _price * val;
      } else {
        _price = _price * _numEntries;
      }
      //print("$key: ${EntryFormUtil.isPaid(eventEntries, key)}");
      //print("price * entries: ${_price/val} * ${val} = $_price");
      Widget _priceText = new Text("Fee: \$${(_price).toStringAsFixed(2)}", style: new TextStyle(fontSize: 16.0));
      //if(EntryFormUtil.isPaid(eventEntries, key)) {
      if(isPaidFee) {
        _priceText = new Text("Paid: \$${(_price).toStringAsFixed(2)}", style: new TextStyle(fontSize: 16.0, color: new Color(0xff00e5ff)));
      }

      _children.add(
          new Row(
            children: <Widget>[
              new Expanded(child: new Text(eventParticipant.name, style: new TextStyle(fontSize: 22.0))),
              _priceText
            ],
          )
      );
      // add to total
      if(!isPaidFee) {
        _total += _price;
      }
      _children.add(
        new Wrap(
          children: <Widget>[
            new Text(key, style: new TextStyle(fontFamily: "Montserrat-Light")),
            /*new Container(
              decoration: new BoxDecoration(
                  borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                  color: Colors.white,
                  border: new Border.all(
                    width: 2.0,
                    color: const Color(0xFF313746),
                    style: BorderStyle.solid,
                  ),
              ),
              margin: const EdgeInsets.only(left: 10.0),
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: new Text("Entries: ${val}", style: new TextStyle(fontFamily: "Montserrat-Light", color: Colors.black, fontWeight: FontWeight.bold)),
            )*/
          ],
        ));
      _children.add(new Padding(padding: const EdgeInsets.only(bottom: 20.0)));
    });

    return new Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _children,
      ),
    );
  }

  Future _handleSelect() {
    Map<String, String> _selection = {};
    for(var _ticket in admissionTickets) {
      _selection.putIfAbsent(_ticket.content, () => _ticket);
    }
    return showSelectionDialog(context, "Admission Tickets", 490.0, _selection)
        .then((selected){
      return selected;
    });
  }

  Widget _generateTicketItem(_ticket, isPaid, Function p) {
    return new InkWell(
      onTap: (){
        if(!isPaid) {
          _handleSelect().then((selected) {
            Function.apply(p, [selected]);
          });
        }
      },
      child: new Container(
        padding: const EdgeInsets.all(5.0),
        decoration: new BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
          border: new Border.all(
            width: 2.0,
            color: const Color(0xFF313746),
            style: BorderStyle.solid,
          ),
        ),
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text(_ticket.content,
                  overflow: TextOverflow.clip,
                  style: new TextStyle(
                      fontFamily: "Montserrat-Light", color: Colors.black)
              ),
            ),
            new Container(
              margin: const EdgeInsets.only(right: 5.0),
              alignment: Alignment.centerRight,
              child: new Icon(FontAwesomeIcons.ticketAlt, color: !isPaid ? Colors.black : new Color(0xff00e5ff)),
            ),
          ],
        ),
      ),
    );
  }

  Widget generateAdmissionTickets(eventParticipant, Map entries) {
    List<Widget> _children = [];
    List<Widget> _rowItems = [];
    double _ticketFee = 0.0;
    bool isPaid = false;

    if(eventParticipant.user is Couple || eventParticipant.user is Group) {
      List<Widget> wrapChildren = [];
      List _users = [];

      //print(eventParticipant?.toJson());

      if(eventParticipant.user is Couple) {
        _users = eventParticipant.user.couple;
      } else if(eventParticipant.user is Group) {
        _users.addAll(eventParticipant.user.members);
      }
      wrapChildren.addAll(_users.map((_user){
        var _ticketMap = participantTickets[eventParticipant];
        //_ticketMap.forEach((key, val) => print(key?.toJson()));
        var _ticket = _ticketMap[_user];
        //print(_ticket?.toJson());
        var ticketPaid = _ticket?.isPaid != null ? _ticket.isPaid : false;
        _ticketFee += _ticket?.amount != null ? _ticket.amount : 0.0;

        if(!isPaid || (isPaid && !ticketPaid)) {
          isPaid = ticketPaid;
        }

        return _generateTicketItem(_ticket, ticketPaid, (selected){
          if(selected != null) {
            setState(() {
              _ticketMap[_user] = selected;
            });
          }
        });
      }).toList());

      _rowItems.add(
          new Expanded(
            child: new Wrap(
              runSpacing: 4.0,
              spacing: 4.0,
              children: wrapChildren,
            )
          )
      );
    }
    else if(eventParticipant.user is User) {
      var _ticket = participantTickets[eventParticipant];
      isPaid = _ticket?.isPaid != null ? _ticket.isPaid : false;
      _ticketFee += _ticket?.amount != null ? _ticket.amount : 0.0;
      _rowItems.add(new Expanded(
        child: new InkWell(
          onTap: () {
            if(!isPaid) {
              _handleSelect().then((selected){
                if(selected != null) {
                  setState(() {
                    participantTickets[eventParticipant] = selected;
                  });
                }
              });
            }
          },
          child: new Text(_ticket.content,
              overflow: TextOverflow.clip,
              style: new TextStyle(fontFamily: "Montserrat-Light", color: Colors.black)
          ),
        ),
      ));
      _rowItems.add(
          new Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: new Container(
                alignment: Alignment.centerRight,
                child: new Icon(FontAwesomeIcons.ticketAlt, color: !isPaid ? Colors.black : new Color(0xff00e5ff)),
              )
          )
      );
    }

    Widget _priceText = new Text("Fee: \$${_ticketFee.toStringAsFixed(2)}", style: new TextStyle(fontSize: 16.0));
    if(isPaid)
      _priceText = new Text("Paid: \$${(_ticketFee).toStringAsFixed(2)}", style: new TextStyle(fontSize: 16.0, color: new Color(0xff00e5ff)));

    _children.add(
        new Row(
          children: <Widget>[
            new Expanded(child: new Text(eventParticipant.name, style: new TextStyle(fontSize: 22.0))),
            _priceText
          ],
        )
    );

    _children.add(
      new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _rowItems,
                )
            ),
          )
        ],
      )
      /*new Row(
        children: <Widget>[
          new Expanded(
            child: new DropdownButtonHideUnderline(
              child: new Container(
                padding: const EdgeInsets.only(left: 5.0),
                height: 35.0,
                color: Colors.white,
                child: new Theme(
                  data: new ThemeData.light(),
                  child: new DropdownButton(
                      style: new TextStyle(fontFamily: "Montserrat-Light", color: Colors.black, fontSize: 13.0),
                      iconSize: 30.0,
                      value: "DA",
                      items: admissionTickets.map((value) {
                        return new DropdownMenuItem<String>(
                            value: value.code,
                            child: new Container(
                              width: 285.0,
                              child: new Text(value.content),
                            )
                        );
                      }).toList(),
                      onChanged: (val){
                        /*setState(() {
                            if (val != null)
                              _dropValue = val;
                          });*/
                      }
                  ),
                ),
              )
            )
          )
        ],
      )*/
    );

    // add admission Fees to total
    if(!isPaid)
      setState((){_total += _ticketFee;});

    return new Container(
      //color: Colors.amber,
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _total = 0.0;
    String _imgAsset = "mainframe_assets/images/add_via_email.png";
    List<Widget> _children = [];
    if(participantEntries != null){
      participantEntries.forEach((key, val){
        _children.add(generateContentItem(key, val));
        // display admission ticket(s)
        _children.add(generateAdmissionTickets(key, val));
      });
    }

    /*print("ticket owners:");
    participantTickets.forEach((part,val){
      print(part?.user?.toJson());
      if(!(val is Map))
        print(val?.toJson());
      else
        print(val);
    });*/

    return new Scaffold(
      appBar: new MFAppBar("REGISTRATION SUMMARY", context),
      body: new ListView(
        children: _children
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
                child: new Text("Total Fees: \$${(_total).toStringAsFixed(2)}", style: new TextStyle(fontSize: 17.0)),
              ),
              new InkWell(
                onTap: (){
                  if(_total > 0.0) {
                    checkout.totalAmount = _total;
                    Navigator.of(context).pushNamed("/checkoutEntry");
                  }
                },
                child: _total > 0 ? new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
                  ),
                  width: 115.0,
                  height: 40.0,
                  child: new Center(child: new Text("Pay Fees", style: new TextStyle(fontSize: 17.0))),
                ) : new Wrap(),
              )
            ],
          ),
        ),
      ),
    );
  }
}