import 'HeatPerson.dart';
import 'package:intl/intl.dart';

class Heat {
  final formatter = new DateFormat("MM/dd/yyyy");
  final timeFormatter = new DateFormat("HH:mm");

  DateTime date;
  String desc;
  String name;
  String session;
  DateTime time;
  List<SubHeat> subHeats;

  Heat({this.date, this.desc, this.name, this.session, this.time, this.subHeats});

  Heat.fromSnapshot(var s) {
    date = formatter.parse(s["date"]);
    desc = s["desc"];
    name = s["name"];
    session = s["session"];
    time = timeFormatter.parse(s["time"]);
    if(s["subHeat"] != null) {
      subHeats = [];
      var _subHeats = s["subHeat"];
      _subHeats.forEach((itm){
        subHeats.add(new SubHeat.fromSnapshot(itm));
      });
    }
  }
}

class SubHeat {
  String age;
  String dance;
  String id;
  String level;
  String type;
  List<HeatEntry> entries;
  
  SubHeat({this.age, this.dance, this.id, this.level, this.type, this.entries});
  
  SubHeat.fromSnapshot(var s){
    age = s["age"];
    dance = s["dance"];
    id = s["id"];
    level = s["level"];
    type = s["type"];
    if(s["coupleEntries"]["coupleEntry"] != null) {
      entries = [];
      var _entries = s["coupleEntries"]["coupleEntry"];
      _entries.forEach((item){
        entries.add(new HeatEntry.fromSnapshot(item));
      });
    }
  }
}

class HeatEntry {
  HeatCouple couple;

  HeatEntry({this.couple});

  HeatEntry.fromSnapshot(var s) {
    couple = new HeatCouple.fromSnapshot(s);
  }
}