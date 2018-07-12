import 'EventEntry.dart';
import 'EventTicket.dart';
import 'MFEvent.dart';
import 'FormEntry.dart';

class UserEvent {
  dynamic usrEntryForm;
  List tickets;
  dynamic info;

  UserEvent({this.usrEntryForm, this.tickets, this.info});

  UserEvent.fromSnapshot(var s){
    usrEntryForm = new EventEntry.fromSnapshot(s["form_entry"]);
    if(s["tickets"] != null) {
      tickets = [];
      var _tickets = s["tickets"];
      _tickets.forEach((_ticket){
        tickets.add(new EventTicket.fromSnapshot(_ticket));
      });
    }
    info = new MFEvent.fromSnapshotEntry(s["event"]);
  }

  toJson() {
    return {
      "entry_forms": usrEntryForm.toJson(),
      "tickets": tickets?.map((val) => val?.toJson())?.toList(),
      "info": info.toJson(),
    };
  }

}