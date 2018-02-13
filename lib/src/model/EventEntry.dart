import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:myapp/src/model/MFEvent.dart';

class EventEntry {
  final formatterSrc = new DateFormat("yyyy-MM-dd");

  dynamic event;
  dynamic formEntry;
  dynamic participant;
  List<LevelEntry> levels;

  EventEntry({this.event, this.formEntry, this.levels, this.participant});

  EventEntry.fromSnapshot();

  toJson() {
    return {
      "event": event.toJson(),
      "form": formEntry.toJson(),
      "participant": participant.toJson(),
      "levels": levels?.map((val) => val?.toJson())?.toList()
    };
  }
}

class LevelEntry {
  String levelName;
  List<SubCategoryEntry> ageMap;

  LevelEntry({this.ageMap, this.levelName});

  LevelEntry.fromSnapshot();

  toJson() {
      return {
        "level": levelName,
        "ageCategories": ageMap.map((val) => val.toJson()).toList()
      };
  }
}

class SubCategoryEntry {
  String ageCategory;
  Map<String, bool> subCategoryMap;

  SubCategoryEntry({this.subCategoryMap, this.ageCategory});

  SubCategoryEntry.fromSnapshot(val) :
        subCategoryMap = val;

  toJson() {
    return {
      "ageCategory": ageCategory,
      "subCategoryValues": subCategoryMap
    };
  }
}