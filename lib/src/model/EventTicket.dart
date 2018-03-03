import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/model/MFEvent.dart';
import 'package:myapp/src/model/FormEntry.dart';

class EventTicket {
  MFEvent event;
  Ticket ticket;
  User ticketOwner;

  EventTicket({this.event, this.ticket, this.ticketOwner});

  EventTicket.fromSnapshot(var s) {
    event = new MFEvent.fromSnapshotEntry(s["event"]);
    ticketOwner = new User.fromDataSnapshot(s["ticketOwner"]);
    ticket = new Ticket.fromSnapshot(s["ticket"]);
  }

  toJson() {
    return {
      "event": event.toJson(),
      "ticketOwner": ticketOwner.toJson(),
      "ticket": ticket.toJson(),
    };
  }
}