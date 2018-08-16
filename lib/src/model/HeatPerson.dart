
List setListObject(s, objName, {objArrParams}) {
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
        if(objArrParams == null)
          objArr.add(initFromSnapshot(objName, val));
        else
          objArr.add(initFromSnapshot(objName, val, objArr: objArrParams));
      });
    }
    else {
      if(objArrParams == null)
        objArr.add(initFromSnapshot(objName, _objects));
      else
        objArr.add(initFromSnapshot(objName, _objects, objArr: objArrParams));
    }
    return objArr;
  }
  return null;
}

dynamic initFromSnapshot(String objName, val, {objArr}) {
  switch (objName.toLowerCase()) {
    case 'couple':
      HeatCouple _heatCouple = objArr == null ? new HeatCouple.fromSnapshot(val) : new HeatCouple.fromSnapshot(val, objArr: objArr);
      return _heatCouple;
    case 'person':
      HeatPerson _person = objArr == null ? new HeatPerson.fromSnapshot(val) : new HeatPerson.fromSnapshot(val, objArr: objArr);
      return _person;
    case 'studio':
      HeatStudio _studio = new HeatStudio.fromSnapshot(val);
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

  HeatPerson.fromSnapshot(var s, {objArr}) {
    NdcaUsabdaNumber = s["NdcaUsabdaNumber"];
    competitorNumber = s["competitorNumber"];
    firstName = s["firstName"];
    gender = s["gender"];
    lastName = s["lastName"];
    nickName = s["nickName"];
    personKey = s["personKey"];
    personType = s["personType"];
    if(s["studioKey"] != null && objArr != null) {
      String sKey = s["studioKey"];
      for(var arrItem in objArr){
        if(arrItem?.studioKey != null && arrItem.studioKey == sKey) {
          studio = arrItem;
          break;
        }
      }
    }
  }
}

class HeatCouple {
  String coupleKey;
  List<HeatPerson> persons;

  HeatCouple({this.coupleKey, this.persons});

  HeatCouple.fromSnapshot(var s, {objArr}) {
    coupleKey = s["coupleKey"];
    if(s["personKeys"]["personKey"] != null && objArr != null) {
      persons = [];
      List personKeys = s["personKeys"]["personKey"];
      for(var arrItem in objArr) {
        if(arrItem?.personKey != null && personKeys.contains(arrItem.personKey)) {
          persons.add(arrItem);
        }
      }
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