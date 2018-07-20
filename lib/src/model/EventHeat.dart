import 'HeatPerson.dart';
import 'Heat.dart';

class EventHeat {
  List<HeatCouple> couples;
  List<Heat> heats;
  List<HeatPerson> persons;
  List<HeatStudio> studios;

  EventHeat({this.couples, this.heats, this.persons, this.studios});

  EventHeat.fromSnapshot(var s) {
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
        heats.add(new Heat.fromSnapshot(item));
      });
    }
    if(s["studios"] != null) {
      studios = [];
      setListObject(s, "studio")?.forEach((studioTemp) => studios.add(studioTemp));
    }
  }
}