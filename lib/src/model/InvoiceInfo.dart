import 'MFEvent.dart';
import 'FormEntry.dart';
import 'User.dart';

class BillingInfo {
  String name;
  String address;

  BillingInfo({this.name, this.address});

  toJson() {
    return {
      "name": name,
      "address": address,
    };
  }
}

class Surcharge {
  String description;
  double percentage;
  double amount;

  Surcharge({this.description, this.percentage, this.amount});

  Surcharge.fromFinance(Finance f) {
    description = f.description;
    percentage = f.surcharge;
  }

  toJson() {
    return {
      "description": description,
      "percentage": percentage,
      "amount": amount
    };
  }
}

class ParticipantEntry {
  String name;
  double price;

  ParticipantEntry({this.name, this.price});

  toJson() {
    return {
      "name": name,
      "price": price,
    };
  }
}

class InvoiceParticipants {
  String formName;
  List<User> participants;
  List<ParticipantEntry> participantEntries;

  InvoiceParticipants({this.formName, this.participants, this.participantEntries});

  toJson() {
    return {
      "formName": formName,
      "participants": participants?.map((val) => val?.toJson())?.toList(),
      "participantEntries": participantEntries?.map((val) => val?.toJson())?.toList(),
    };
  }
}

class InvoiceInfo {
  double totalAmount;
  Surcharge surcharge;
  MFEvent event;
  BillingInfo billingInfo;
  List<Ticket> tickets;
  List<InvoiceParticipants> entries;

  InvoiceInfo({this.totalAmount, this.surcharge, this.event, this.billingInfo, this.tickets, this.entries});

  toJson() {
    return {
      "totalAmount": totalAmount,
      "surcharge": surcharge.toJson(),
      "event": event.toJson(),
      "billingInfo": billingInfo?.toJson(),
      "tickets": tickets?.map((val) => val?.toJson())?.toList(),
      "entries": entries?.map((val) => val?.toJson())?.toList(),
    };
  }
}