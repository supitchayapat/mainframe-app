import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:myapp/src/model/MFEvent.dart';
import 'package:myapp/src/model/FormEntry.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/FormType.dart';
import 'package:myapp/src/freeform/ShowDanceSolo.dart';
import 'package:stripe_plugin/stripe_plugin.dart';

class EventEntry {
  final formatterSrc = new DateFormat("yyyy-MM-dd");

  dynamic event;
  dynamic formEntry;
  dynamic participant;
  List<LevelEntry> levels;
  dynamic freeForm;
  StripeCard payment;

  int danceEntries;
  int paidEntries;

  EventEntry({this.event, this.formEntry, this.levels, this.participant, this.danceEntries, this.freeForm, this.payment, this.paidEntries});

  EventEntry.fromSnapshot(var s) {
    event = new MFEvent.fromSnapshotEntry(s["event"]);
    formEntry = new FormEntry.fromSnapshot(s["form"]);
    if(s["participant"] != null && s["participant"]["coupleName"] != null) {
      participant = new Couple.fromSnapshot(s["participant"]);
    }
    else if(s["participant"] != null && s["participant"]["groupName"] != null) {
      participant = new Group.fromSnapshot(s["participant"]);
    } else if(s["participant"] != null) {
      participant = new User.fromDataSnapshot(s["participant"]);
    }
    if(s["levels"] != null) {
      levels = [];
      var _lvls = s["levels"];
      _lvls.forEach((_lvl){
        levels.add(new LevelEntry.fromSnapshot(_lvl));
      });
    }
    danceEntries = s["danceEntries"];
    paidEntries = s["paidEntries"];
    if(formEntry.type == FormType.SOLO) {
      //print(s["freeForm"]);
      freeForm = new ShowDanceSolo.fromSnapshot(s["freeForm"]);
      //print("FREEFORM: ${freeForm.toJson()}");
    }
    else if (formEntry.type == FormType.GROUP) {
      freeForm = s["freeForm"];
      print("freeForm: $freeForm");
    }

    if(s["payment"] != null) {
      payment = new StripeCard.fromSnapshot(s["payment"]);
    }
  }

  toJson() {
    var _freeFormData;
    if(freeForm is ShowDanceSolo)
      _freeFormData = freeForm?.toJson();
    else
      _freeFormData = freeForm;

    return {
      "event": event.toJson(),
      "form": formEntry.toJson(),
      "participant": participant.toJson(),
      "danceEntries": danceEntries,
      "paidEntries": paidEntries,
      "freeForm": _freeFormData,
      "levels": levels?.map((val) => val?.toJson())?.toList(),
      "payment": payment?.toJson(),
    };
  }
}

class LevelEntry {
  String levelName;
  List<SubCategoryEntry> ageMap;

  LevelEntry({this.ageMap, this.levelName});

  LevelEntry.fromSnapshot(var s){
    levelName = s["level"];
    if(s["ageCategories"] != null) {
      ageMap = [];
      var _ageMp = s["ageCategories"];
      _ageMp.forEach((val){
        ageMap.add(new SubCategoryEntry.fromSnapshot(val));
      });
    }
  }

  toJson() {
      return {
        "level": levelName,
        "ageCategories": ageMap.map((val) => val.toJson()).toList()
      };
  }
}

class SubCategoryEntry {
  String ageCategory;
  bool catOpen;
  bool catClosed;
  Map<String, bool> subCategoryMap;

  SubCategoryEntry({this.subCategoryMap, this.catOpen : false, this.catClosed : false, this.ageCategory});

  SubCategoryEntry.fromSnapshot(var s) {
    ageCategory = s["ageCategory"];
    subCategoryMap = s["subCategoryValues"];
    catOpen = s["catOpen"];
    catClosed = s["catClosed"];
  }

  toJson() {
    return {
      "ageCategory": ageCategory,
      "catOpen": catOpen,
      "catClosed": catClosed,
      "subCategoryValues": subCategoryMap
    };
  }
}