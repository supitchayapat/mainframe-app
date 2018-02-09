import 'package:quiver/core.dart';

class FormParticipant {
  String code;
  String content;
  int price;

  FormParticipant({this.code, this.content, this.price});

  FormParticipant.fromSnapshot(var s) {
    code = s["code"];
    content = s["content"];
    price = s["price"];
  }

  toJson() {
    return {
      "code": code,
      "content": content,
      "price": price,
    };
  }

  bool operator ==(o) => o is FormParticipant && o.code == code && o.content == content && o.price == price;
  int get hashCode => hash2(code.hashCode, price.hashCode);
}

class FormPrice {
  int id;
  int content;
  String type;

  FormPrice({this.id, this.content, this.type});

  FormPrice.fromSnapshot(var s) {
    id = s["id"];
    content = s["content"];
    type = s["type"];
  }

  toJson() {
    return {
      "id": id,
      "content": content,
      "type": type,
    };
  }
}


class FormStructure {
  List horizontals;
  List verticals;

  FormStructure({this.horizontals, this.verticals});
}

class FormEntry {
  String formName;
  int order;
  String formType;
  List prices;
  List participants;
  FormStructure structure;
  List lookups;
  List exclusions;

  FormEntry({this.formName, this.order, this.formType, this.prices,
    this.participants, this.structure, this.lookups, this.exclusions});

  FormEntry.fromSnapshot(var s) {
    formName = s["name"];
    order = s["order"];
    formType = s["type"];

    participants = _setListObject(s, "participant");
    prices = _setListObject(s, "price");
  }

  FormPrice getPriceFromList(int priceId) {
    for(var _p in prices){
      //print("$priceId ${_p.toJson()}");
      if(_p.id == priceId) {
        //print("EQUALS!");
        return _p;
      }
    }
    return null;
  }

  dynamic _setListObject(s, objName) {
    if(s["${objName}s"] != null) {
      var _objects = s["${objName}s"][objName];
      print(_objects);
      var objArr = [];
      if(_objects is List) {
        _objects.forEach((val) {
          objArr.add(_initFromSnapshot(objName, val));
        });
      }
      else {
        objArr.add(_initFromSnapshot(objName, _objects));
      }
      return objArr;
    }
    return null;
  }

  dynamic _initFromSnapshot(String objName, val) {
    switch (objName.toLowerCase()) {
      case 'price':
        FormPrice _formPrice = new FormPrice.fromSnapshot(
            val);
        return _formPrice;
      case 'participant':
        FormParticipant _formParticipant = new FormParticipant.fromSnapshot(
            val);
        return _formParticipant;
      default:
        return null;
    }
  }

  toJson() {
    return {
      "formName": formName,
      "order": order,
      "formType": formType,
      "participants": participants.map((val) => val.toJson()).toList(),
      "prices": prices.map((val) => val.toJson()).toList(),
    };
  }
}