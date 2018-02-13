import 'package:quiver/core.dart';
import 'package:myapp/src/enumeration/FormType.dart';

dynamic _setListObject(s, objName) {
  if(s["${objName}s"] != null) {
    var _objects = s["${objName}s"][objName];
    //print(_objects);
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
    case 'horizontal':
      FormHorizontal _formHorizontal = new FormHorizontal.fromSnapshot(
          val);
      return _formHorizontal;
    case 'vertical':
      FormVertical _formVertical = new FormVertical.fromSnapshot(
          val);
      return _formVertical;
    case 'lookup':
      FormLookup _formLookup = new FormLookup.fromSnapshot(
          val);
      return _formLookup;
    case 'element':
      FormLookupElement _formLookupElement = new FormLookupElement.fromSnapshot(
          val);
      return _formLookupElement;
    default:
      return null;
  }
}

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

class FormLookup {
  String id;
  String description;
  List<FormLookupElement> elements;

  FormLookup({this.id, this.description, this.elements});

  FormLookup.fromSnapshot(var s) {
    //print(s);
    id = s["id"];
    description = s["description"];
    if(s["element"] != null) {
      var _elems = s["element"];
      //print(_elems);
      if(_elems is List) {
        elements = [];
        _elems.forEach((_obj) {
          elements.add(_initFromSnapshot("element", _obj));
        });
      } else {
        elements = [];
        elements.add(_initFromSnapshot("element", _elems));
      }
    }
  }

  toJson() {
    return {
      "id": id,
      "description": description,
      "elements": elements?.map((val) => val?.toJson())?.toList(),
    };
  }
}

class FormLookupElement {
  int id;
  int order;
  int grouping;
  String code;
  String content;

  FormLookupElement({this.id, this.order, this.grouping, this.code, this.content});

  FormLookupElement.fromSnapshot(var s) {
    id = s["id"];
    order = s["order"];
    grouping = s["grouping"];
    code = s["code"];
    content = s["content"];
  }

  toJson() {
    return {
      "id": id,
      "order": order,
      "grouping": grouping,
      "code": code,
      "content": content
    };
  }
}

class FormVertical {
  int order;
  String link;

  FormVertical({this.order, this.link});

  FormVertical.fromSnapshot(var s){
    order = s["order"];
    link = s["link"];
  }

  toJson() {
    return {
      "order": order,
      "link": link,
    };
  }
}

class FormHorizontal {
  String position;
  String link;

  FormHorizontal({this.position, this.link});

  FormHorizontal.fromSnapshot(var s){
    position = s["position"];
    link = s["link"];
  }

  toJson() {
    return {
      "position": position,
      "link": link,
    };
  }
}


class FormStructure {
  List<FormVertical> horizontals;
  List<FormHorizontal> verticals;

  FormStructure({this.horizontals, this.verticals});

  FormStructure.fromSnapshot(var s) {
    horizontals = _setListObject(s, "horizontal");
    verticals = _setListObject(s, "vertical");
  }

  toJson() {
    return {
      "horizontals": horizontals?.map((val) => val?.toJson())?.toList(),
      "verticals": verticals?.map((val) => val?.toJson())?.toList(),
    };
  }
}

class FormEntry {
  String formName;
  int order;
  FormType formType;
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
    formType = getFormTypeFromString(s["type"]);

    participants = _setListObject(s, "participant");
    prices = _setListObject(s, "price");
    if(s["structure"] != null) {
      structure = new FormStructure.fromSnapshot(s["structure"]);
    }
    lookups = _setListObject(s, "lookup");
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

  FormLookup getFormLookup(String linkId) {
    if(lookups != null) {
      for(var lookup in lookups) {
        if(lookup.id == linkId) {
          return lookup;
        }
      }
    }
    return null;
  }

  toJson() {
    return {
      "formName": formName,
      "order": order,
      "formType": formType != null ? formType.toString().replaceAll("FormType.", "") : null,
      "participants": participants?.map((val) => val?.toJson())?.toList(),
      "prices": prices?.map((val) => val?.toJson())?.toList(),
      "structure": structure != null ? structure.toJson() : null,
      "lookups": lookups?.map((val) => val?.toJson())?.toList(),
    };
  }
}