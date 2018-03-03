import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/model/EventTicket.dart';

final reference = FirebaseDatabase.instance.reference().child("users");

class TicketDao {

  static retrieveAndSave(event, ticket, ticketOwner) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    final ticketRef = reference.child(fUser.uid).child("tickets");
    EventTicket _ticket;
    Map<String, EventTicket> participantTicket = await getTicketByUser(event.id, ticketOwner);
    if(participantTicket == null) {
      _ticket = new EventTicket(
          event: event,
          ticket: ticket,
          ticketOwner: ticketOwner
      );
      ticketRef.push().set(_ticket.toJson());
    } else {
      participantTicket.forEach((pushId, pTicket){
        pTicket.ticket = ticket;
        ticketRef.child(pushId).set(pTicket.toJson());
      });
    }
  }

  static saveTicket(evtParticipant, ticketMap, event, {isPaid}) async {
    var participant = evtParticipant.user;
    print(participant.toJson());
    if(participant is Couple) {
      [0,1].forEach((_idx) async {
        if(isPaid != null)
          ticketMap[participant.couple[_idx]].isPaid = isPaid;
        // find user
        retrieveAndSave(event, ticketMap[participant.couple[_idx]], participant.couple[_idx]);
      });
    } else if(participant is Group) {
      participant.members.forEach((_user){
        if(isPaid != null)
          ticketMap[_user].isPaid = isPaid;
        // find user
        retrieveAndSave(event, ticketMap[_user], _user);
      });
    }
    else if(participant is User) {
      if(isPaid != null)
        ticketMap.isPaid = isPaid;
      // find user
      retrieveAndSave(event, ticketMap, participant);
    }
  }

  static Future<StreamSubscription> getTickets(eventId, Function p) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    return reference
        .child(fUser.uid)
        .child("tickets")
        .orderByChild("event/id")
        .equalTo(eventId)
        .onValue
        .listen((event) {
      if(event.snapshot?.value != null) {
        Map<String, EventTicket> _evtTickets = {};
        event.snapshot.value.forEach((dataKey, dataVal) {
          _evtTickets.putIfAbsent(dataKey, () => new EventTicket.fromSnapshot(dataVal));
          Function.apply(p, [_evtTickets]);
        });
      }
    });
  }

  static Future<Map<String, EventTicket>> getTicketByUser(eventId, user) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    return reference
        .child(fUser.uid)
        .child("tickets")
        .orderByChild("event/id")
        .equalTo(eventId)
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
        return {
          pushId: ticketSelected
        };
      }
    });
  }
}