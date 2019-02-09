import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class TicketConfig {
  List<TicketColumn> columns;
  List<TicketDate> dates;
  List<ConfigTicket> tickets;

  TicketConfig({this.columns, this.dates});

  TicketConfig.fromSnapshot(var s){
    if(s["columns"] != null) {
      //print("COLUMNS COLUMS: ${s["columns"]["column"]}");
      var _columns = s["columns"]["column"];
      this.columns = [];
      _columns.forEach((itm){
        columns.add(new TicketColumn.fromSnapshot(itm));
      });
    }

    if(s["ticket_dates"] != null) {
      //print("TICKET DATE: ${s["ticket_dates"]["ticket_date"]}");
      var _dates = s["ticket_dates"]["ticket_date"];
      this.dates = [];
      _dates.forEach((itm){
        dates.add(new TicketDate.fromSnapshot(itm));
      });
    }

    if(s["tickets"] != null) {
      var _tickets = s["tickets"]["ticket"];
      this.tickets = [];
      _tickets.forEach((itm){
        tickets.add(new ConfigTicket.fromSnapshot(itm));
      });
    }
  }
}

class TicketColumn {
  String header;
  int order;
  String type;

  TicketColumn({this.type, this.order, this.header});

  TicketColumn.fromSnapshot(var s) {
    header = s["header"];
    order = s["order"];
    type = s["type"];
  }
}

class TicketDate {
  final formatter = new DateFormat("yyyy/MM/dd");

  DateTime date;
  int order;
  List<TicketRows> rows;

  TicketDate({this.date, this.rows, this.order});

  TicketDate.fromSnapshot(var s){
    order = s["order"];
    if(s["date"] != null) {
      date = formatter.parse(s["date"]);
    }
    if(s["rows"] != null) {
      var _rows = s["rows"];
      this.rows = [];
      if(_rows is List) {
        _rows.forEach((itm) {
          rows.add(new TicketRows.fromSnapshot(itm));
        });
      } else {
        rows.add(new TicketRows.fromSnapshot(_rows));
      }
    }
  }
}

class ConfigTicket {
  int id;
  double amount;
  String content;
  int order;
  String session;
  bool dinner_included;
  bool competitor_ticket;

  ConfigTicket({this.id, this.amount, this.content, this.order, this.session, this.dinner_included, this.competitor_ticket});

  ConfigTicket.fromSnapshot(var s) {
    id = s["id"];
    amount = (s["amount"])?.toDouble();
    content = s["content"];
    order = s["order"];
    session = s["session"];
    dinner_included = s["dinner_included"];
    competitor_ticket = s["competitor_ticket"];
  }
}

class TicketRows {
  List<TicketType> types;

  TicketRows({this.types});

  TicketRows.fromSnapshot(var s){
    if(s["types"] != null) {
      //print("S TYPES:");
      //print(s["types"]);
      var _types = s["types"];
      this.types = [];
      if(_types is List) {
        _types.forEach((itm) {
          types.add(new TicketType.fromSnapshot(itm));
        });
      } else {
        types.add(new TicketType.fromSnapshot(_types));
      }
    }
  }
}

class TicketType {
  int id;
  String type;
  String session;
  bool dinner_indicator;
  bool dinner_included;

  TicketType({this.id, this.type, this.session, this.dinner_included, this.dinner_indicator});

  TicketType.fromSnapshot(var s){
    id = s["id"];
    type = s["type"];
    session = s["session"];
    dinner_included = s["dinner_included"];
    dinner_indicator = s["dinner_indicator"];
  }
}