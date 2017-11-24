import 'dart:convert';

class EventEntry {
  List<LevelEntry> levels;

  EventEntry({this.levels});

  EventEntry.fromSnapshot();

  toJson() {
    return {
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