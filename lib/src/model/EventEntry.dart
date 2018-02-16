import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:myapp/src/model/MFEvent.dart';
import 'package:myapp/src/model/FormEntry.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/FormType.dart';
import 'package:myapp/src/freeform/ShowDanceSolo.dart';

class EventEntry {
  final formatterSrc = new DateFormat("yyyy-MM-dd");

  dynamic event;
  dynamic formEntry;
  dynamic participant;
  List<LevelEntry> levels;
  dynamic freeForm;
  int danceEntries;

  EventEntry({this.event, this.formEntry, this.levels, this.participant, this.danceEntries, this.freeForm});

  EventEntry.fromSnapshot(var s) {
    event = new MFEvent.fromSnapshotEntry(s["event"]);
    formEntry = new FormEntry.fromSnapshot(s["form"]);
    if(s["participant"] != null && s["participant"]["coupleName"] != null) {
      participant = new Couple.fromSnapshot(s["participant"]);
    }
    else if(s["participant"] != null) {
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
    if(formEntry.type == FormType.SOLO) {
      //print(s["freeForm"]);
      freeForm = new ShowDanceSolo.fromSnapshot(s["freeForm"]);
      //print("FREEFORM: ${freeForm.toJson()}");
    }
    else if (formEntry.type == FormType.GROUP) {
      freeForm = null;
    }
  }

  toJson() {
    return {
      "event": event.toJson(),
      "form": formEntry.toJson(),
      "participant": participant.toJson(),
      "danceEntries": danceEntries,
      "freeForm": freeForm.toJson(),
      "levels": levels?.map((val) => val?.toJson())?.toList(),
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