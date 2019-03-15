import 'package:flutter/material.dart';
import 'dart:async';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/EntryFormUtil.dart';
import 'package:myapp/src/screen/checkout_entry.dart' as checkout;
import 'package:myapp/src/screen/event_registration.dart' as reg;
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/model/User.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/src/util/ShowTipsUtil.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/src/dao/TicketDao.dart';
import 'package:myapp/src/model/InvoiceInfo.dart';
import 'package:myapp/src/enumeration/FormParticipantType.dart';
import 'package:myapp/src/enumeration/FormType.dart';
import 'package:myapp/src/dao/PaymentDao.dart';
import 'package:myapp/src/screen/ticket_summary_a60.dart' as ticketSummary;
import 'package:myapp/src/screen/studio_details.dart' as studioDetails;
import 'package:myapp/src/util/LoadingIndicator.dart';

var participantEntries;
var eventEntries;
var participants;
Map participantTickets;
Map<String, Map<String, dynamic>> entryForms = {};
List admissionTickets;
Map ticketUsers;

class entry_summary extends StatefulWidget {
  @override
  _entry_summaryState createState() => new _entry_summaryState();
}

class _entry_summaryState extends State<entry_summary> {
  double _total = 0.0;
  double _totalTicketAdmissionFees = 0.0;
  double _totalTicketSessionFees = 0.0;
  int _competitorTickets = 0;
  int _sessionTickets = 0;
  String _paymentMode = "";
  double financeCharge = 0.0;
  var _evtTickets;
  double _recievedAmount;
  bool _isTicketRequired = false;

  var tipsTimer;
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
    _total = 0.0;
    _totalTicketAdmissionFees = 0.0;
    _totalTicketSessionFees = 0.0;
    _competitorTickets = 0;
    _sessionTickets = 0;
    // world of dance event payment mode e-transfer
    _paymentMode = "e-transfer";
    _evtTickets = [];
    _recievedAmount = 0.0;
    _isTicketRequired = false;

    // logging for crashlytics
    global.messageLogs.add("Entry Summary Screen load.");
    AnalyticsUtil.setCurrentScreen("Entry Summary", screenClassName: "MainScreen");

    tipsTimer = ShowTips.showTips(context, "entrySummary");

    entryForms = {};
    if(reg.eventItem.formEntries != null) {
      var _formEntries = reg.eventItem.formEntries;
      //var _admission = reg.eventItem.admission;
      _formEntries.forEach((_entry){
        Map<String, dynamic> _priceMap = {};
        _entry.participants.forEach((_p){
          //print("${_entry.formName} ${_p.code} getPrice: ${_entry.getPriceFromList(_p.price).toJson()}");
          _priceMap.putIfAbsent(_p.code, () => _entry.getPriceFromList(_p.price));
        });
        //print("pricemap: $_priceMap");
        entryForms.putIfAbsent(_entry.name, () => _priceMap);
      });
      /*if(_admission?.tickets != null && _admission.tickets.length > 0) {
        admissionTickets = [];
        admissionTickets.addAll(_admission.tickets);
        //admissionTickets.forEach((val) => print(val.toJson()));
      }*/
    }

    // get Tickets from TicketDao
    TicketDao.getEventTickets(reg.eventItem, (evtTickets){
      print("EVT TICKETS: ${evtTickets}");
      setState(() {
      if(evtTickets != null && evtTickets.length > 0) {
        for(var itm in evtTickets){
          if(itm.attendee_tickets != null && !itm.attendee_tickets.isEmpty) {
            for(var aTicket in itm.attendee_tickets) {
              if(aTicket.tickets_selected != null && !aTicket.tickets_selected.isEmpty) {
                for(var _selected in aTicket.tickets_selected) {
                  if(_selected?.competitor_ticket != null && _selected.competitor_ticket) {
                    _competitorTickets += 1;
                    _totalTicketAdmissionFees += _selected.amount_total;
                  }
                  else {
                    _sessionTickets += 1;
                    _totalTicketSessionFees += _selected.amount_total;
                  }
                }
              }
            }
          }
        }

        //print("LENGTH: ${eventTickets.length}");
        //print("Total admission tickets: ${_competitorTickets}");
        //print("Total admission amount: ${_totalTicketAdmissionFees}");
        //print("Total session tickets: ${_sessionTickets}");
        //print("Total session amount: ${_totalTicketSessionFees}");

        _evtTickets = evtTickets;
      }
      });
    });

    if(reg.eventItem.ticketConfig?.admission_required != null)
      _isTicketRequired = reg.eventItem.ticketConfig.admission_required;
    print("IS TICKET REQUIRED: $_isTicketRequired");

    if(reg.eventItem?.finance != null) {
      financeCharge = reg.eventItem?.finance.surcharge / 100;
    }

    PaymentDao.getEtransferPaymentReceivedAmount(reg.eventItem).then((recievedAmount){
      _recievedAmount = recievedAmount;
    });

    //print("participantTickets $participantTickets");
    //print("ticketUsers $ticketUsers");
    /*if(participantEntries != null) {
      if(participantTickets == null)
        participantTickets = {};

      print("INITIALIZE TICKETS");
      participantEntries.forEach((_participant, val) {
        //populateParticipantTickets(_participant, (ticketUsers == null || ticketUsers.isEmpty) ? null : ticketUsers);
      });
    }*/
    //print(_entryForms.length);
    //print(_entryForms);
  }

  void populateParticipantTickets(_participant, Map ticketMap) {
    if(_participant.user is Couple) {
      Map _couple = {};
      var ticketCouple1 = (ticketMap != null && ticketMap.isNotEmpty) ? ticketMap[_participant.user.couple[0]] : null;
      var ticketCouple2 = (ticketMap != null && ticketMap.isNotEmpty) ? ticketMap[_participant.user.couple[1]] : null;
      if(ticketMap == null || !ticketMap.containsKey(_participant.user.couple[0]))
        participantTickets.putIfAbsent(_participant.user.couple[0], () => (ticketCouple1 != null ? ticketCouple1 : admissionTickets[0]));
      if(ticketMap == null || !ticketMap.containsKey(_participant.user.couple[1]))
        participantTickets.putIfAbsent(_participant.user.couple[1], () => (ticketCouple2 != null ? ticketCouple2 : admissionTickets[0]));
    }
    else if(_participant.user is Group) {
      Map _members = {};
      for(var _member in _participant.user.members) {
        var memberTicket = (ticketMap != null && ticketMap.isNotEmpty) ? ticketMap[_member] : null;
        if(ticketMap == null || !ticketMap.containsKey(_member))
          participantTickets.putIfAbsent(_member, () => (memberTicket != null ? memberTicket : admissionTickets[0]));
      }
    } else {
      //print("participant: ${_participant?.user?.toJson()}");
      var participantTicket = (ticketMap != null && ticketMap.isNotEmpty) ? ticketMap[_participant.user] : null;
      //print("participantTicket: ${participantTicket?.toJson()}");
      if(ticketMap == null || !ticketMap.containsKey(_participant.user))
        participantTickets.putIfAbsent(_participant.user, () => (participantTicket != null ? participantTicket : admissionTickets[0]));
      //print("THE TICKET: ${participantTickets[_participant]?.toJson()}");
    }
  }

  @override
  void dispose() {
    super.dispose();
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
        if(_entry?.formEntry?.name == key && eventParticipant.user == _entry?.participant) {
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

      // add to total
      if(!isPaidFee) {
        _children.add(
            new Row(
              children: <Widget>[
                new Expanded(child: new Text(eventParticipant.name, style: new TextStyle(fontSize: 22.0))),
                _priceText
              ],
            )
        );

        _total += _price;
        // add ticket fees
        _total += _totalTicketSessionFees + _totalTicketAdmissionFees;

        _children.add(
            new Wrap(
              children: <Widget>[
                new Text(key, style: new TextStyle(fontFamily: "Montserrat-Light")),
              ],
            ));
        _children.add(new Padding(padding: const EdgeInsets.only(bottom: 20.0)));
      }
    });

    if(_children.isNotEmpty) {
      return new Container(
        margin: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _children,
        ),
      );
    } else {
      return null;
    }
  }

  Future _handleSelect() {
    Map<String, dynamic> _selection = {};
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

  Widget generateAdmissionTickets(_user, _ticket) {
    List<Widget> _children = [];
    List<Widget> _rowItems = [];
    double _ticketFee = 0.0;
    bool isPaid = false;

    //print(_user?.toJson());

    _ticketFee = _ticket.amount;
    _rowItems.add(new Expanded(
      child: new InkWell(
        onTap: () {
          if(!isPaid) {
            _handleSelect().then((selected){
              if(selected != null) {
                setState(() {
                  participantTickets[_user] = selected;
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

    Widget _priceText = new Text("Fee: \$${_ticketFee.toStringAsFixed(2)}", style: new TextStyle(fontSize: 16.0));

    _children.add(
        new Row(
          children: <Widget>[
            new Expanded(child: new Text("${_user.first_name} ${_user.last_name}", style: new TextStyle(fontSize: 22.0))),
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

  Widget generateTickets(admissionTicketType, ticketCount, _ticketFee) {
    List<Widget> _children = [];

    Widget _priceText = new Text("Fee: \$${_ticketFee.toStringAsFixed(2)}", style: new TextStyle(fontSize: 16.0));
    _children.add(
        new Row(
          children: <Widget>[
            new Expanded(
              child: new Text("${admissionTicketType}  x  ${ticketCount}", style: new TextStyle(fontSize: 16.0))
            ),
            _priceText
          ],
        )
    );

    return new Container(
      //color: Colors.amber,
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _children,
      ),
    );
  }

  String getSessionCode(String formName) {
    String retVal;
    if(reg.eventItem != null && reg.eventItem?.formEntries != null) {
      for(var _formEntry in reg.eventItem.formEntries) {
        if(_formEntry.name == formName && _formEntry?.sessionCode != null) {
          retVal = _formEntry.sessionCode;
          break;
        }
      }
    }
    return retVal;
  }

  void _handleCompetitorTickets() {
    Map<String, Set<String>> _participantSession = {};
    for(var _pEntries in participants) {
      String sessCode;
      print("_partEntries: ${participantEntries[_pEntries]}");
      for(var _ent in participantEntries[_pEntries].entries) {
        sessCode = getSessionCode(_ent.key);
      }
      print("sessCode: $sessCode");
      if (_pEntries.user is Couple) {
        Set<String> _coupleSessionCodes;
        _pEntries.user.couple.forEach((itm){
          print("pEntries: ${itm.first_name} ${itm.last_name}");
          if(_participantSession.containsKey("${itm.first_name} ${itm.last_name}")) {
            _coupleSessionCodes = _participantSession["${itm.first_name} ${itm.last_name}"];
            _coupleSessionCodes.add(sessCode);
          } else {
            _coupleSessionCodes = new Set();
            _coupleSessionCodes.add(sessCode);
            _participantSession.putIfAbsent("${itm.first_name} ${itm.last_name}", () => _coupleSessionCodes);
          }
        });
      } else if (_pEntries.user is Group) {
        Set<String> _grpSessionCodes;
        _pEntries.user.members.forEach((itm){
          print("pEntries: ${itm.first_name} ${itm.last_name}");
          if(_participantSession.containsKey("${itm.first_name} ${itm.last_name}")) {
            _grpSessionCodes = _participantSession["${itm.first_name} ${itm.last_name}"];
            _grpSessionCodes.add(sessCode);
          } else {
            _grpSessionCodes = new Set();
            _grpSessionCodes.add(sessCode);
            _participantSession.putIfAbsent("${itm.first_name} ${itm.last_name}", () => _grpSessionCodes);
          }
        });
      } else {
        Set<String> _soloSessionCodes;
        print("pEntries: ${_pEntries.user.first_name} ${_pEntries.user.last_name}");
        if(_participantSession.containsKey("${_pEntries.user.first_name} ${_pEntries.user.last_name}")) {
          _soloSessionCodes = _participantSession["${_pEntries.user.first_name} ${_pEntries.user.last_name}"];
          _soloSessionCodes.add(sessCode);
        } else {
          _soloSessionCodes = new Set();
          _soloSessionCodes.add(sessCode);
          _participantSession.putIfAbsent("${_pEntries.user.first_name} ${_pEntries.user.last_name}", () => _soloSessionCodes);
        }
      }
    }
    print(_participantSession);
    // loop session codes and save ticket
    for(var _entry in _participantSession.entries) {
      for(var _setItem in _entry.value) {
        print("${_entry.key} : ${_setItem}");
        TicketDao.autoAddCompetitorTickets(reg.eventItem, _setItem, _entry.key);
      }
    }
  }

  void _handlePaymentEtransfer() {
    // add competitor tickets
    _handleCompetitorTickets();

    double _sumAmount = (_total.toDouble() * financeCharge) + _total.toDouble();
    Surcharge surcharge = new Surcharge.fromFinance(reg.eventItem.finance);
    surcharge.amount = (_total.toDouble() * financeCharge);
    // create new invoice info
    InvoiceInfo info = new InvoiceInfo(
      event: reg.eventItem,
      totalAmount: _sumAmount,
      surcharge: surcharge,
      newEntries: true,
    );
    info.entries = [];
    info.tickets = [];
    info.billingInfo = new BillingInfo(name: studioDetails.studioCtrl.text, address: studioDetails.addressCtrl.text);

    try {
      eventEntries?.forEach((key, val) {
        if (val?.payment == null) {
          bool isInvoice = val.paidEntries != val?.danceEntries;
          print("${val.paidEntries} != ${val.danceEntries}");
          // pay this entry
          val.paidEntries = val?.danceEntries;
          //val.payment = data;
          // new Invoice Participants
          InvoiceParticipants invParticipants = new InvoiceParticipants(
              formName: val?.formEntry?.name);
          invParticipants.participants = [];
          invParticipants.participantEntries = [];
          FormParticipantType fType;
          if (val?.participant != null) {
            if (val.participant is Couple) {
              invParticipants.participants.addAll(val.participant.couple);
              fType = FormParticipantType.COUPLE;
            } else if (val.participant is Group) {
              invParticipants.participants.addAll(val.participant.members);
              fType = FormParticipantType.GROUP;
            } else if (val.participant is User) {
              invParticipants.participants.add(val.participant);
              fType = FormParticipantType.SOLO;
            }
          }

          double _price = EntryFormUtil.getPriceFromForm(
              entryForms[val?.formEntry?.name], val.participant, fType);
          if (val?.levels != null) {
            for (var _lvl in val.levels) {
              for (var _ageMap in _lvl.ageMap) {
                _ageMap.subCategoryMap.forEach((_k, _v) {
                  if (_v["selected"]) {
                    //print("key: $_k paid: ${_v["paid"]}");
                    if (!_v["paid"]) {
                      String _content = EntryFormUtil.getLookupDescription(
                          val.formEntry, _k, "DANCES");
                      ParticipantEntry _pEntry = new ParticipantEntry(
                          name: "${_ageMap.ageCategory} ${_lvl.levelName
                              .toUpperCase()} $_content", price: _price);
                      //print(_pEntry.toJson());
                      invParticipants.participantEntries.add(_pEntry);
                    }
                    // not yet paid
                    _v["paid"] = false;
                  }
                });
              }
            }
          }
          else if (val?.freeForm != null) {
            // free form GROUP
            if (val.formEntry.type == FormType.GROUP ||
                val.formEntry.type == FormType.SOLO) {
              String _entryName = "";
              if (val.formEntry.type == FormType.GROUP)
                _entryName =
                "${val.freeForm["age"]} ${val.freeForm["dance"]} ${val
                    .freeForm["event_type"]}";
              if (val.formEntry.type == FormType.SOLO)
                _entryName = val.freeForm.dance;

              ParticipantEntry _pEntry = new ParticipantEntry(
                  name: _entryName, price: _price);
              invParticipants.participantEntries.add(_pEntry);
            }
          }

          if (isInvoice) {
            //print("INV PARTICIPANTS");
            //print(invParticipants.toJson());
            info.entries.add(invParticipants);
          }
        }
      });

      // add the tickets
      if (_evtTickets != null && !_evtTickets.isEmpty) {
        info.tickets = [];
        info.tickets.addAll(_evtTickets);
      }
      // add receieved amount
      if (_recievedAmount != null) {
        info.receivedAmount = _recievedAmount;
      }
      else {
        info.receivedAmount = 0.0;
      }

      // save InvoiceInfo
      PaymentDao.saveEtransferPayment(reg.eventItem, info).then((retVal){
        MainFrameLoadingIndicator.hideLoading(context);
        Navigator.pushNamed(context, "/paymentNotice");
      }).catchError((err){
        MainFrameLoadingIndicator.hideLoading(context);
        showMainFrameDialog(
            context, "ERROR", "An error occurred during payment transaction. Please contact support."
        ).then((_thn){
          MainFrameLoadingIndicator.hideLoading(context);
        });
      });
    } catch(err) {
      showMainFrameDialog(
        context, "ERROR", "An error occurred during payment transaction. Please contact support."
      ).then((_thn){
        MainFrameLoadingIndicator.hideLoading(context);
      });
    }
  }

  int getNumberOfParticipants() {
    List<String> _participantNameBucket = [];
    for(var _pt in participants) {
      if (_pt.user is Couple) {
        for(var usr in _pt.user.couple) {
          String _name = "${usr.first_name} ${usr.last_name}";
          if(!_participantNameBucket.contains(_name)) {
            _participantNameBucket.add(_name);
          }
        }
      }
      else if (_pt.user is Group) {
        if(_pt.user?.members != null) {
          for(var usr in _pt.user.members) {
            String _name = "${usr.first_name} ${usr.last_name}";
            if(!_participantNameBucket.contains(_name)) {
              _participantNameBucket.add(_name);
            }
          }
        }
      } else {
        String _name = "${_pt.user.first_name} ${_pt.user.last_name}";
        if(!_participantNameBucket.contains(_name)) {
          _participantNameBucket.add(_name);
        }
      }
    }
    return _participantNameBucket.length;
  }

  @override
  Widget build(BuildContext context) {
    _total = 0.0;
    String _imgAsset = "mainframe_assets/images/add_via_email.png";
    List<Widget> _children = [];
    if(participantEntries != null){
      participantEntries.forEach((key, val){
        //print("participantEntries val: $val");
        Widget _entryFeeContent = generateContentItem(key, val);
        if(_entryFeeContent != null)
          _children.add(_entryFeeContent);
        // display admission ticket(s)
        //_children.add(generateAdmissionTickets(key, val));
      });

      if(_children.isEmpty) {
        _children.add(new Container(
          //color: Colors.amber,
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0, top: 20.0),
          child: new Text("All Entry fees are paid.", style: new TextStyle(fontSize: 18.0)),
        ));
      }
    }

    /*if(participantTickets != null && participantTickets.isNotEmpty) {
      participantTickets.forEach((key, val){
        _children.add(generateAdmissionTickets(key, val));
      });
    }*/

    _children.add(new Container(
      //color: Colors.amber,
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0, top: 20.0),
        child: new Row(
          children: <Widget>[
            new Container(
                child: new Text("Tickets", style: new TextStyle(fontSize: 22.0))
            ),
            new InkWell(
              onTap: () {
                print("participants LENGTH: ${participants.length}");
                ticketSummary.ticketConf = reg.eventItem.ticketConfig;
                ticketSummary.participants = [];
                ticketSummary.participants.addAll(participants);

                ticketSummary.participants.forEach((evtParticipant){
                  evtParticipant.formEntries = [];
                  eventEntries.forEach((key, itm){
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
                    borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                    border: new Border.all(
                      color: Colors.white,
                      style: BorderStyle.solid,
                    )
                ),
                margin: const EdgeInsets.only(left: 20.0),
                padding: const EdgeInsets.all(4.0),
                child: new Row(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: new Text("view tickets", style: new TextStyle(color: new Color(0xff00e5ff))),
                    ),
                    new Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: new Icon(FontAwesomeIcons.externalLinkAlt, color: new Color(0xff00e5ff), size: 16.0)
                    ),
                  ],
                ),
              ),
            )
          ],
        )
    ));

    if(_competitorTickets > 0) {
      _children.add(
        generateTickets("Admission Ticket(s)", _competitorTickets, _totalTicketAdmissionFees)
      );
    }
    if(_sessionTickets > 0) {
      _children.add(
        generateTickets("Session Ticket(s)", _sessionTickets, _totalTicketSessionFees)
      );
    }

    /*print("ticket owners:");
    participantTickets.forEach((part,val){
      //print(part?.user?.toJson());
      print(part?.toJson());
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

                  // logging for crashlytics
                  global.messageLogs.add("Pay Fees button pressed.");
                  AnalyticsUtil.sendAnalyticsEvent("pay_fees_pressed", params: {
                    'screen': 'entry_summary'
                  });
                  if(_total > 0.0 && _paymentMode != "e-transfer") {
                    checkout.totalAmount = _total;
                    Navigator.of(context).pushNamed("/checkoutEntry");
                  }
                  else if(_total > 0.0 && _paymentMode == "e-transfer") {
                    // get number of participants
                    int _participantsCount = 0;
                    _participantsCount = getNumberOfParticipants();
                    print("PARTICIPANTS COUNT: $_participantsCount");
                    //if(_competitorTickets == _participantsCount) {
                      MainFrameLoadingIndicator.showLoading(context);
                      print("E-TRANSFER SAVING");
                      _handlePaymentEtransfer();
                    /*} else {
                      print("PARTICIPANTS TYPE: ${participants.runtimeType}");
                      showMainFrameDialog(context, "Unmatched Tickets", "Number of Participants (${_participantsCount}) does not match to Competitor Admission Tickets (${_competitorTickets}) purchased.");
                    }*/
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