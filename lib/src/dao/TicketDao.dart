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
      TicketEvent _existing;
      snapshot.value.forEach((key, val){
        _existing = new TicketEvent.fromSnapshot(snapshot.value);
        _existing.pushId = key;
      });
      return _existing;
    }).catchError((err){
      print("Error found on retrieving data: $err");
    });
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
}