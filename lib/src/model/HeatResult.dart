import 'package:intl/intl.dart';
import 'HeatPerson.dart';

class ResultHeat {
  final formatter = new DateFormat("MM/dd/yyyy");
  final timeFormatter = new DateFormat("HH:mm");

  DateTime date;
  String desc;
  String name;
  String session;
  DateTime time;
  List<ResultSubHeat> subHeats;

  ResultHeat({this.date, this.desc, this.name, this.session, this.time, this.subHeats});

  ResultHeat.fromSnapshot(var s) {
    date = formatter.parse(s["date"]);
    desc = s["desc"];
    name = s["name"];
    session = s["session"];
    time = timeFormatter.parse(s["time"]);
    if(s["subHeat"] != null) {
      subHeats = [];
      var _subHeats = s["subHeat"];
      _subHeats.forEach((itm){
        subHeats.add(new ResultSubHeat.fromSnapshot(itm));
      });
    }
  }
}

class ResultSubHeat {
  String age;
  String dance;
  String id;
  String level;
  String type;
  HeatResult result;

  ResultSubHeat({this.age, this.dance, this.id, this.level, this.type, this.result});

  ResultSubHeat.fromSnapshot(var s) {
    age = s["age"];
    dance = s["dance"];
    id = s["id"];
    level = s["level"];
    type = s["type"];
  }
}

class HeatResult {
  List<HeatJudge> judgingPanels;
  List<String> scoreHeaders;
  List<Mark> marks;

  HeatResult({this.judgingPanels, this.scoreHeaders, this.marks});

  HeatResult.fromSnapshot(var s) {
    if(s["judgingPanels"] != null) {
      judgingPanels = [];
      var _panels = s["judgingPanels"];
      _panels.forEach((item){
        judgingPanels.add(new HeatJudge.fromSnapshot(item));
      });
    }
    if(s["scoreHeaders"] != null) {
      scoreHeaders = [];
      var _headers = s["scoreHeaders"];
      _headers.forEach((item){
        scoreHeaders.add(item);
      });
    }
    if(s["marks"]["mark"] != null) {
      marks = [];
      var _marks = s["marks"]["mark"];
      _marks.forEach((item){
        marks.add(new Mark.fromSnapshot(item));
      });
    }
  }
}

class Mark {
  String coupleKey;
  List<String> texts;

  Mark({this.coupleKey, this.texts});

  Mark.fromSnapshot(var s){
    coupleKey = s["coupleKey"];
    if(s["texts"] != null) {
      texts = [];
      var _texts = s["texts"];
      _texts.forEach((item){
        texts.add(item);
      });
    }
  }
}