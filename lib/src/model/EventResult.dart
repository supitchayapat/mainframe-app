import 'HeatPerson.dart';
import 'HeatResult.dart';

class EventResult {
  List<HeatCouple> couples;
  List<ResultHeat> heats;
  List<HeatJudge> judges;
  List<HeatPerson> persons;
  List<HeatStudio> studios;

  EventResult({this.couples, this.heats, this.judges, this.persons, this.studios});

  EventResult.fromSnapshot(var s) {
    if(s["studios"] != null) {
      studios = [];
      setListObject(s, "studio")?.forEach((studioTemp) => studios.add(studioTemp));
    }
    if(s["persons"] != null) {
      persons = [];
      setListObject(s, "person", objArrParams: studios)?.forEach((personTemp) => persons.add(personTemp));
    }
    if(s["couples"] != null) {
      couples = [];
      setListObject(s, "couple", objArrParams: persons)?.forEach((coupleTemp) => couples.add(coupleTemp));
    }
    if(s["judges"] != null) {
      judges = [];
      setListObject(s, "judge")?.forEach((judgeTemp) => judges.add(judgeTemp));
    }
    if(s["heats"]["heat"] != null) {
      heats = [];
      var _heats = s["heats"]["heat"];
      _heats.forEach((item){
        heats.add(new ResultHeat.fromSnapshot(item, judgeArr: judges, coupleArr: couples));
      });
    }
  }
}