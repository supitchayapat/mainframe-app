import 'package:intl/intl.dart';

class ParticipantAttendeeTicket {
  String name;
  var type; // attendee or participant
  var user;

  ParticipantAttendeeTicket({this.name, this.type, this.user});

  toJson() {
    return {
      "name": name,
      "type": type,
      "user": user?.toJson(),
    };
  }
}

class TicketEvent {
  String pushId;
  String attendee; // full name
  bool isParticipant;
  List<AttendeeTicket> attendee_tickets;

  TicketEvent({this.pushId, this.attendee, this.isParticipant, this.attendee_tickets});

  TicketEvent.fromSnapshot(var s) {
    attendee = s["attendee"];
    isParticipant = s["isParticipant"];
    if(s["attendee_tickets"] != null) {
      attendee_tickets = [];
      var _attendeeTickets = s["attendee_tickets"];
      _attendeeTickets.forEach((itm){
        attendee_tickets.add(new AttendeeTicket.fromSnapshot(itm));
      });
    }
  }

  toJson() {
    return {
      "attendee": attendee,
      "isParticipant": isParticipant,
      "attendee_tickets": attendee_tickets?.map((val) => val?.toJson())?.toList(),
    };
  }
}

class AttendeeTicket {
  final formatter = new DateFormat("yyyy/MM/dd");

  DateTime ticket_date;
  String type; // day
  int button_id; // type id
  bool dinner; // has dinner
  int total_tickets;
  List<TicketSelected> tickets_selected;

  AttendeeTicket({this.ticket_date, this.type, this.button_id, this.dinner, this.total_tickets, this.tickets_selected});

  AttendeeTicket.fromSnapshot(var s) {
    if(s["ticket_date"] != null) {
      ticket_date = formatter.parse(s["ticket_date"]);
    }
    type = s["type"];
    button_id = s["button_id"];
    dinner = s["dinner"];
    total_tickets = s["total_tickets"];
    if(s["tickets_selected"] != null) {
      tickets_selected = [];
      var _selectedTickets = s["tickets_selected"];
      _selectedTickets.forEach((itm){
        tickets_selected.add(new TicketSelected.fromSnapshot(itm));
      });
    }
  }

  toJson() {
    return {
      "ticket_date": ticket_date!= null ? formatter.format(ticket_date) : formatter.format(new DateTime.now()),
      "type": type,
      "button_id": button_id,
      "dinner": dinner,
      "total_tickets": total_tickets,
      "tickets_selected": tickets_selected?.map((val) => val?.toJson())?.toList(),
    };
  }
}

class TicketSelected {
  String content;
  int id;
  int count;
  double ticket_amount;
  double amount_total;

  TicketSelected({this.content, this.id, this.amount_total, this.count, this.ticket_amount});

  TicketSelected.fromSnapshot(var s) {
    content = s["content"];
    id = s["id"];
    count = s["count"];
    ticket_amount = (s["ticket_amount"])?.toDouble();
    amount_total = (s["amount_total"])?.toDouble();
  }

  toJson() {
    return {
      "content": content,
      "id": id,
      "count": count,
      "ticket_amount": ticket_amount,
      "amount_total": amount_total,
    };
  }
}