
class EventDanceCategory {
  String category;
  String code;
  int order;
  List<DanceSubCategory> subCategories;

  EventDanceCategory({this.category, this.code, this.order, this.subCategories});

  EventDanceCategory.fromSnapshot(var s) {
    category = s["category"];
    code = s["code"];
    order = s["order"];
    if(s["subCategories"] != null) {
      subCategories = (s["subCategories"] as List).map((val) => new DanceSubCategory.fromSnapshot(val)).toList();
    }
    else {
      subCategories = null;
    }
  }

  toJson() {
    return {
      "category": category,
      "code": code,
      "order": order,
      "subCategories": subCategories?.map((val) => val.toJson())
    };
  }
}

class DanceSubCategory {
  String subCategory;
  String code;
  int order;
  int id;

  DanceSubCategory({this.id, this.subCategory, this.code, this.order});

  DanceSubCategory.fromSnapshot(var s) :
        id = s["id"],
        subCategory = s["subCategory"],
        code = s["code"],
        order = s["order"];

  toJson() {
    return {
      "id": id,
      "subCategory": subCategory,
      "code": code,
      "order": order
    };
  }
}