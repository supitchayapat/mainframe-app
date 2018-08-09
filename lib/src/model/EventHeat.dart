import 'HeatPerson.dart';
import 'Heat.dart';

class EventHeat {
  List<HeatCouple> couples;
  List<Heat> heats;
  List<HeatPerson> persons;
  List<HeatStudio> studios;

  EventHeat({this.couples, this.heats, this.persons, this.studios});

  EventHeat.fromSnapshot(var s) {
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
    if(s["heats"]["heat"] != null) {
      heats = [];
      var _heats = s["heats"]["heat"];
      _heats.forEach((item){
        heats.add(new Heat.fromSnapshot(item, coupleArr: couples));
      });
    }
  }
}