import 'HeatPerson.dart';
import 'package:intl/intl.dart';

class Heat {
  final formatter = new DateFormat("MM/dd/yyyy");
  final timeFormatter = new DateFormat("HH:mm");

  String date;
  String desc;
  String name;
  String session;
  String time;
  List<SubHeat> subHeats;

  Heat({this.date, this.desc, this.name, this.session, this.time, this.subHeats});

  Heat.fromSnapshot(var s, {coupleArr}) {
    //date = formatter.parse(s["date"]);
    date = s["date"];
    desc = s["desc"];
    name = s["name"];
    session = s["session"];
    //time = timeFormatter.parse(s["time"]);
    time = s["time"];
    if(s["subHeat"] != null) {
      subHeats = [];
      var _subHeats = s["subHeat"];
      _subHeats.forEach((itm){
        subHeats.add(new SubHeat.fromSnapshot(itm, coupleArr: coupleArr));
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
  
  SubHeat.
  fromSnapshot(var s, {coupleArr}){
    age = s["age"];
    dance = s["dance"];
    id = s["id"];
    level = s["level"];
    type = s["type"];
    if(s["coupleEntries"]["coupleEntry"] != null && coupleArr != null) {
      entries = [];
      var _entries = s["coupleEntries"]["coupleEntry"];
      _entries.forEach((item){
        HeatEntry entry = new HeatEntry.fromSnapshot(item);
        if(entry.contestantKey != null) {
          for(var cp in coupleArr) {
            if(cp.coupleKey == entry.contestantKey) {
              entry.contestant = cp;
              entries.add(entry);
              break;
            }
          }
        }
      });
    }
  }
}

class HeatEntry {
  var contestant;
  String contestantKey;

  HeatEntry({this.contestantKey});

  HeatEntry.fromSnapshot(var s) {
    contestantKey = s["coupleKey"];
  }
}