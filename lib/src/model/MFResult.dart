

class MFResult {

  List couples;
  List heats;
  List judges;
  List persons;
  List studios;

  MFResult({this.couples, this.heats, this.judges, this.persons, this.studios});

  MFResult.fromSnapshot(var s) {
    couples = new List();
    heats = new List();
    judges = new List();
    persons = new List();
    studios = new List();
  }
}