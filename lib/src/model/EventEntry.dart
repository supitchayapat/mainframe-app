import 'dart:convert';
import 'package:intl/intl.dart';

class EventEntry {
  final formatterSrc = new DateFormat("yyyy-MM-dd");

  String eventTitle;
  DateTime startDate;
  DateTime stopDate;
  DateTime deadline;
  String formName;
  List<LevelEntry> levels;

  EventEntry({this.formName, this.levels, this.eventTitle, this.startDate, this.stopDate, this.deadline});

  EventEntry.fromSnapshot();

  toJson() {
    return {
      "eventTitle": eventTitle,
      "startDate": startDate!= null ? formatterSrc.format(startDate) : formatterSrc.format(new DateTime.now()),
      "stopDate": stopDate!= null ? formatterSrc.format(stopDate) : formatterSrc.format(new DateTime.now()),
      "deadline": deadline!= null ? formatterSrc.format(deadline) : formatterSrc.format(new DateTime.now()),
      "formName": formName,
      "levels": levels.map((val) => val.toJson()).toList()
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