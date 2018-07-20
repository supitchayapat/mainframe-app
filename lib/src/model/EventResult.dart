import 'HeatPerson.dart';
import 'HeatResult.dart';

class EventResult {
  List<HeatCouple> couples;
  List<HeatResult> heats;
  List<HeatJudge> judges;
  List<HeatPerson> persons;
  List<HeatStudio> studios;

  EventResult({this.couples, this.heats, this.judges, this.persons, this.studios});

  EventResult.fromSnapshot(var s) {
    if(s["couples"] != null) {
      couples = [];
      setListObject(s, "couple")?.forEach((coupleTemp) => couples.add(coupleTemp));
    }
    if(s["persons"] != null) {
      persons = [];
      setListObject(s, "person")?.forEach((personTemp) => persons.add(personTemp));
    }
    if(s["heats"]["heat"] != null) {
      heats = [];
      var _heats = s["heats"]["heat"];
      _heats.forEach((item){
        heats.add(new HeatResult.fromSnapshot(item));
      });
    }
    if(s["studios"] != null) {
      studios = [];
      setListObject(s, "studio")?.forEach((studioTemp) => studios.add(studioTemp));
    }
    if(s["judges"] != null) {
      judges = [];
      setListObject(s, "judge")?.forEach((judgeTemp) => judges.add(judgeTemp));
    }
  }
}