import 'package:intl/intl.dart';
import 'HeatPerson.dart';

class ResultHeat {
  final formatter = new DateFormat("MM/dd/yyyy");
  final timeFormatter = new DateFormat("HH:mm");

  String date;
  String desc;
  String name;
  String session;
  String time;
  List<ResultSubHeat> subHeats;

  ResultHeat({this.date, this.desc, this.name, this.session, this.time, this.subHeats});

  ResultHeat.fromSnapshot(var s, {judgeArr, coupleArr}) {
    //date = formatter.parse(s["date"]);
    date = s["date"];
    desc = s["desc"];
    name = s["name"];
    session = s["session"];
    //time = timeFormatter.parse(s["time"]);
    time = s["time"];
    if(s["subHeats"]["subHeat"] != null) {
      subHeats = [];
      var _subHeats = s["subHeats"]["subHeat"];
      _subHeats.forEach((itm){
        subHeats.add(new ResultSubHeat.fromSnapshot(itm, judgeArr: judgeArr, coupleArr: coupleArr));
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

  ResultSubHeat.fromSnapshot(var s, {judgeArr, coupleArr}) {
    age = s["age"];
    dance = s["dance"];
    id = s["id"];
    level = s["level"];
    type = s["type"];
    if(s["result"] != null) {
      result = new HeatResult.fromSnapshot(s["result"], judgeArr: judgeArr, coupleArr: coupleArr);
    }
  }
}

class HeatResult {
  List<HeatJudge> judgingPanels;
  List<String> scoreHeaders;
  List<Mark> marks;

  HeatResult({this.judgingPanels, this.scoreHeaders, this.marks});

  HeatResult.fromSnapshot(var s, {judgeArr, coupleArr}) {
    if(s["judgingPanelKeys"] != null && judgeArr != null) {
      judgingPanels = [];
      var _panelKeys = s["judgingPanelKeys"];
      List _panels = _panelKeys.split("|");
      _panels.forEach((item){
        for(var judge in judgeArr) {
          if(judge.judgeKey == item) {
            judgingPanels.add(judge);
            break;
          }
        }
      });
    }
    if(s["scoreHeaders"] != null) {
      scoreHeaders = [];
      var _scoreHeaders = s["scoreHeaders"];
      List _headers = _scoreHeaders.split("|");
      _headers.forEach((item){
        scoreHeaders.add(item);
      });
    }
    if(s["marks"]["mark"] != null && coupleArr != null) {
      marks = [];
      var _marks = s["marks"]["mark"];
      _marks.forEach((item){
        Mark mark = new Mark.fromSnapshot(item);
        if(mark.contestantKey != null) {
          for (var cp in coupleArr) {
            if(mark.contestantKey == cp.coupleKey) {
              mark.contestant = cp;
              marks.add(mark);
              break;
            }
          }
        }
      });
    }
  }
}

class Mark {
  var contestantKey;
  var contestant;
  List<String> texts;

  Mark({this.contestantKey, this.texts});

  Mark.fromSnapshot(var s){
    contestantKey = s["coupleKey"];
    if(s["text"] != null) {
      texts = [];
      var _text = s["text"];
      List _texts = _text.split("|");
      _texts.forEach((item){
        texts.add(item);
      });
    }
  }
}