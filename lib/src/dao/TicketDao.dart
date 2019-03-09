import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/model/EventTicket.dart';
import 'package:myapp/src/model/Ticket.dart';

final reference = FirebaseDatabase.instance.reference().child("users");

class TicketDao {

  static Future retrieveAndSave(event, ticket, ticketOwner) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    final ticketRef = reference.child(fUser.uid).child("events").child(event.evtPId).child("tickets");
    EventTicket _ticket;
    Map<String, EventTicket> participantTicket = await getTicketByUser(event.evtPId, ticketOwner);
    if(participantTicket == null) {
      _ticket = new EventTicket(
          event: event,
          ticket: ticket,
          ticketOwner: ticketOwner
      );
      return ticketRef.push().set(_ticket.toJson()).then((_nil){
        return _ticket;
      });
    } else {
      //print(ticketOwner?.toJson());
      //print(participantTicket);
      participantTicket.forEach((pushId, pTicket){
        pTicket.ticket = ticket;
        ticketRef.child(pushId).set(pTicket.toJson());
        _ticket = pTicket;
      });
      return _ticket;
    }
  }

  static Future saveTicket(evtParticipant, ticketMap, event, {isPaid}) async {
    //var participant = evtParticipant.user;
    //print(evtParticipant.toJson());
    print("SAVING TICKET:");
    /*if(evtParticipant is Couple) {
      [0,1].forEach((_idx) async {
        if(isPaid != null)
          ticketMap[evtParticipant.couple[_idx]].isPaid = isPaid;
        // find user
        retrieveAndSave(event, ticketMap[evtParticipant.couple[_idx]], evtParticipant.couple[_idx]);
      });
    } else if(evtParticipant is Group) {
      evtParticipant.members.forEach((_user){
        if(isPaid != null)
          ticketMap[_user].isPaid = isPaid;
        // find user
        retrieveAndSave(event, ticketMap[_user], _user);
      });
    }*/
    if(evtParticipant is User) {
      if(isPaid != null)
        ticketMap.isPaid = isPaid;
      // find user
      return retrieveAndSave(event, ticketMap, evtParticipant);
    }
  }

  static Future saveEventTickets(evt, TicketEvent ticketEvent) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    TicketEvent _existing = await getExistingTicketEvent(fUser, evt, ticketEvent);
    if(_existing != null) {
      return reference.child(fUser.uid)
          .child("events")
          .child(evt.evtPId)
          .child("tickets")
          .child(_existing.pushId)
          .set(ticketEvent.toJson());
    }
    else {
      return reference.child(fUser.uid)
          .child("events")
          .child(evt.evtPId)
          .child("tickets")
          .push()
          .set(ticketEvent.toJson());
    }
  }

  static getExistingTicketEvent(fUser, evt, TicketEvent ticketEvent) async {
    print("ATTENDEE: ${ticketEvent.attendee}");
    return reference.child(fUser.uid)
        .child("events")
        .child(evt.evtPId)
        .child("tickets")
        .orderByChild("attendee")
        .equalTo(ticketEvent.attendee)
        .once()
        .then((snapshot){
      print("SNAPSHOT FOUND: ${snapshot.value}");
      TicketEvent _existing;
      for(var entry in snapshot.value.entries) {
        _existing = new TicketEvent.fromSnapshot(entry.value);
        _existing.pushId = entry.key;
      }
      return _existing;
    }).catchError((err){
      print("Error found on retrieving data: $err");
    });
  }

  static Future isTicketRequired(evt, Function p) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    return null;
  }
  
  static Future getEventTickets(evt, Function p) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    return reference.child(fUser.uid)
        .child("events")
        .child(evt.evtPId)
        .child("tickets")
        .once()
        .then((snapshot){
      if(snapshot.value != null) {
        List<TicketEvent> _tickets = [];
        snapshot.value.forEach((dataKey, dataVal) {
          TicketEvent _ticketEvt = new TicketEvent.fromSnapshot(dataVal);
          _ticketEvt.pushId = dataKey;
          _tickets.add(_ticketEvt);
        });
        // back to callback
        Function.apply(p, [_tickets]);
      }
    });
  }

  static Future<StreamSubscription> getTickets(evt, Function p) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    return reference
        .child(fUser.uid)
        .child("events")
        .child(evt.evtPId)
        .child("tickets")
        //.orderByChild("event/id")
        //.equalTo(eventId)
        .onValue
        .listen((event) {
      if(event.snapshot?.value != null) {
        Map<String, EventTicket> _evtTickets = {};
        event.snapshot.value.forEach((dataKey, dataVal) {
          //_evtTickets.putIfAbsent(dataKey, () => new EventTicket.fromSnapshot(dataVal));
          Function.apply(p, [_evtTickets]);
        });
      }
    });
  }

  static Future<Map<String, EventTicket>> getTicketByUser(eventPId, user) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    return reference
        .child(fUser.uid)
        .child("events")
        .child(eventPId)
        .child("tickets")
        //.orderByChild("event/id")
        //.equalTo(eventId)
        .once()
        .then((_snapshot){
      if(_snapshot.value != null && _snapshot.value.length > 0) {
        EventTicket ticketSelected;
        String pushId = "";
        _snapshot.value.forEach((key, dataVal){
          EventTicket _ticket = new EventTicket.fromSnapshot(dataVal);
          if(user != null) {
            if(_ticket.ticketOwner == user) {
              ticketSelected = _ticket;
              pushId = key;
            }
          }
        });
        if(pushId.isNotEmpty) {
          return {
            pushId: ticketSelected
          };
        } else {
          return null;
        }
      }
    });
  }

  static Future autoRemoveCompetitorTickets(evt, sessionCode, competitorName) async {
    var ticketConf = evt.ticketConfig;
    var _ticketConf;
    var _ticketType;
    var _ticketDate;
    ticketConf?.tickets.forEach((itm) {
      if(itm.session == sessionCode && (itm.competitor_ticket != null && itm.competitor_ticket)) {
        // session ticket found. add them on the list
        _ticketConf = itm;
      }
    });
    // get specific ticket date
    ticketConf?.dates.forEach((itm) {
      itm?.rows.forEach((itm1){
        itm1?.types.forEach((itm2){
          if(itm2.session == sessionCode) {
            _ticketType = itm2;
            _ticketDate = itm;
          }
        });
      });
    });

    if(_ticketConf != null && _ticketType != null && _ticketDate != null) {
      // 2. find attendee ticket
      TicketEvent _competitorTicketEvt = new TicketEvent(
          attendee: competitorName);
      FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
      TicketEvent _existing = await getExistingTicketEvent(
          fUser, evt, _competitorTicketEvt);
      print("existing: ${_existing?.toJson()}");
      if (_existing != null) {
        // 2. attendee/competitor found on event tickets
        // 2.1 traverse attendee_tickets and find the match ticket id from (1)
        bool isFound = false;
        TicketSelected _tsRemoval;
        AttendeeTicket _atRemoval;
        for (AttendeeTicket _at in _existing.attendee_tickets) {
          for (TicketSelected _ts in _at.tickets_selected) {
            if(_ticketConf.id == _ts.id) {
              // ticket was found. delete ticket
              isFound = true;
              print("Ticket was found. delete ticket");
              if(_at.total_tickets == 1) {
                // remove entire AttendeeTicket
                _atRemoval = _at;
              } else {
                // remove ticket selected
                _tsRemoval = _ts;
              }
              break;
            }
          }
          if(_tsRemoval != null) {
            _at.tickets_selected.remove(_tsRemoval);
          }
          if(isFound) {
            break;
          }
        }
        if(_atRemoval != null) {
          if(_existing.attendee_tickets.length > 1) {
            // remove attendee ticket
            _existing.attendee_tickets.remove(_atRemoval);
            saveEventTickets(evt, _existing);
          } else {
            // remove using push ID
            reference.child(fUser.uid)
                .child("events")
                .child(evt.evtPId)
                .child("tickets")
                .child(_existing.pushId)
                .remove();
          }
        }
      }
    }
  }

  static Future autoAddCompetitorTickets(evt, sessionCode, competitorName) async {
    print("auto add competitor ticket");
    // find if attendee has existing tickets and it belongs to this session
    //  1. get particular ticket (ticketConfig) according to the FORM's session
    //  2. if attendee/competitor is found on event tickets, then:
    //      2.1 traverse attendee_tickets and find the match ticket id from (1)
    //      2.2 if ticket ID is found, no new ticket is needed to be added
    //      2.3 if ticket ID not found, add new ticket on attendee_tickets
    //          2.3.1 get specific ticket_date that matches the session
    //          2.3.1 if session found on ticket_date. use date and id to save attendee_ticket
    //  3. if attendee/competitor not found, then:
    //      3.1 create attendee_tickets (same method in 2.3.1)
    //      3.2 add tickets using @TicketEvent object. PushId is added

    // 1. get particular ticket (ticketConfig) according to the FORM's session
    var ticketConf = evt.ticketConfig;
    var _ticketConf;
    var _ticketType;
    var _ticketDate;
    ticketConf?.tickets.forEach((itm) {
      if(itm.session == sessionCode && (itm.competitor_ticket != null && itm.competitor_ticket)) {
        // session ticket found. add them on the list
        _ticketConf = itm;
      }
    });
    // get specific ticket date
    ticketConf?.dates.forEach((itm) {
      itm?.rows.forEach((itm1){
        itm1?.types.forEach((itm2){
          if(itm2.session == sessionCode) {
            _ticketType = itm2;
            _ticketDate = itm;
          }
        });
      });
    });

    print("ticketConf: $_ticketConf");
    print("ticketType: $_ticketType");
    print("ticketDate: $_ticketDate");
    // check if TicketConfig found
    if(_ticketConf != null && _ticketType != null && _ticketDate != null) {
      // 2. find attendee ticket
      TicketEvent _competitorTicketEvt = new TicketEvent(
          attendee: competitorName);
      FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
      TicketEvent _existing = await getExistingTicketEvent(
          fUser, evt, _competitorTicketEvt);
      print("existing: ${_existing?.toJson()}");
      if (_existing != null) {
        // 2. attendee/competitor found on event tickets
        // 2.1 traverse attendee_tickets and find the match ticket id from (1)
        bool isFound = false;
        for (AttendeeTicket _at in _existing.attendee_tickets) {
          for (TicketSelected _ts in _at.tickets_selected) {
            if(_ticketConf.id == _ts.id) {
              // ticket was found. no need to add new
              isFound = true;
              print("Ticket was found no need to add");
              break;
            }
          }
          if(isFound) {
            break;
          }
        }
        if(!isFound) {
          print("ticket not found. add attendee ticket");
          // No competitor ticket yet. Add one
          // Find the right @AttendeeTicket on attendee_tickets
          bool foundTicketDate = false;
          for (AttendeeTicket _at in _existing.attendee_tickets) {
            if(_at.ticket_date == _ticketDate.date && _at.button_id == _ticketType.id) {
              // found ticket date
              foundTicketDate = true;
              TicketSelected _selected = new TicketSelected(
                  id: _ticketConf.id,
                  amount_total: _ticketConf.amount,
                  content: _ticketConf.content,
                  count: 1,
                  ticket_amount: _ticketConf.amount,
                  competitor_ticket: _ticketConf.competitor_ticket
              );
              if(_at.tickets_selected == null) {
                _at.tickets_selected = [];
              }
              _at.tickets_selected.add(_selected);
              _at.total_tickets += 1;
            }
          }
          // if not found ticket date
          if(!foundTicketDate) {
            print("ticketDate not found. adding a new one");
            TicketSelected _selected = new TicketSelected(
                id: _ticketConf.id,
                amount_total: _ticketConf.amount,
                content: _ticketConf.content,
                count: 1,
                ticket_amount: _ticketConf.amount,
                competitor_ticket: _ticketConf.competitor_ticket
            );
            List<TicketSelected> _ts = [];
            _ts.add(_selected);

            AttendeeTicket _attendeeTicket = new AttendeeTicket(
                button_id: _ticketType.id,
                dinner: _ticketType.dinner_indicator,
                ticket_date: _ticketDate.date,
                type: _ticketType.type,
                total_tickets: 1,
                tickets_selected: _ts
            );
            _existing.attendee_tickets.add(_attendeeTicket);
          }
          print("saving new event ticket");
          saveEventTickets(evt, _existing);
        }
      } else {
        print("competitor not found. adding event ticket for competitor");
        // 3. attendee/competitor not found
        TicketEvent _eTicket = new TicketEvent(attendee: competitorName, isParticipant: true);
        TicketSelected _selected = new TicketSelected(
            id: _ticketConf.id,
            amount_total: _ticketConf.amount,
            content: _ticketConf.content,
            count: 1,
            ticket_amount: _ticketConf.amount,
            competitor_ticket: _ticketConf.competitor_ticket
        );
        List<TicketSelected> _ts = [];
        _ts.add(_selected);

        AttendeeTicket _attendeeTicket = new AttendeeTicket(
            button_id: _ticketType.id,
            dinner: _ticketType.dinner_indicator,
            ticket_date: _ticketDate.date,
            type: _ticketType.type,
            total_tickets: 1,
            tickets_selected: _ts
        );
        _eTicket.attendee_tickets = [];
        _eTicket.attendee_tickets.add(_attendeeTicket);
        print("saving competitor ticket.");
        saveEventTickets(evt, _eTicket);
      }
    }
  }
}