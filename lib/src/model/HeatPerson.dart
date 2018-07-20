
List setListObject(s, objName) {
  String objNames = objName+"s";
  if(objName == "exclude") {
    objNames = "exclusions";
  }

  if(s[objNames] != null) {
    var _objects;
    try {
      _objects = s[objNames][objName];
    } catch(e){
      _objects = s[objNames];
    }
    //print(_objects);
    List objArr = [];
    if(_objects is List) {
      _objects.forEach((val) {
        objArr.add(initFromSnapshot(objName, val));
      });
    }
    else {
      objArr.add(initFromSnapshot(objName, _objects));
    }
    return objArr;
  }
  return null;
}

dynamic initFromSnapshot(String objName, val) {
  switch (objName.toLowerCase()) {
    case 'couple':
      HeatCouple _heatCouple = new HeatCouple.fromSnapshot(
          val);
      return _heatCouple;
    case 'person':
      HeatPerson _person = new HeatPerson.fromSnapshot(
          val);
      return _person;
    case 'studio':
      HeatStudio _studio = new HeatStudio.fromSnapshot(
          val);
      return _studio;
    case 'judge':
      HeatJudge _judge = new HeatJudge.fromSnapshot(
          val);
      return _judge;
    default:
      return null;
  }
}

class HeatPerson {
  String NdcaUsabdaNumber;
  String competitorNumber;
  String firstName;
  String gender;
  String lastName;
  String nickName;
  String personKey;
  String personType;
  HeatStudio studio;

  HeatPerson({this.NdcaUsabdaNumber, this.competitorNumber, this.firstName, this.gender, this.lastName,
  this.nickName, this.personKey, this.personType, this.studio});

  HeatPerson.fromSnapshot(var s) {
    NdcaUsabdaNumber = s["NdcaUsabdaNumber"];
    competitorNumber = s["competitorNumber"];
    firstName = s["firstName"];
    gender = s["gender"];
    lastName = s["lastName"];
    nickName = s["nickName"];
    personKey = s["personKey"];
    personType = s["personType"];
    if(s["studio"] != null) {
      studio = new HeatStudio.fromSnapshot(s["studio"]);
    }
  }
}

class HeatCouple {
  String coupleKey;
  List<HeatPerson> persons;

  HeatCouple({this.coupleKey, this.persons});

  HeatCouple.fromSnapshot(var s) {
    coupleKey = s["coupleKey"];
    if(s["persons"] != null) {
      persons = [];
      setListObject(s, "person")?.forEach((personTemp) => persons.add(personTemp));
    }
  }
}

class HeatStudio {
  String independentInvoice;
  String name;
  String studioKey;

  HeatStudio({this.independentInvoice, this.name, this.studioKey});

  HeatStudio.fromSnapshot(var s) {
    independentInvoice = s["independentInvoice"];
    name = s["name"];
    studioKey = s["studioKey"];
  }
}

class HeatJudge {
  String firstName;
  String lastName;
  String judgeKey;
  String judgeNumber;

  HeatJudge({this.firstName, this.lastName, this.judgeKey, this.judgeNumber});

  HeatJudge.fromSnapshot(var s) {
    firstName = s["firstName"];
    lastName = s["lastName"];
    judgeKey = s["judgeKey"];
    judgeNumber = s["judgeNumber"];
  }
}