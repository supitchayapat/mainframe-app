
class EventDanceCategory {
  String category;
  int order;
  List<DanceSubCategory> subCategories;

  EventDanceCategory({this.category, this.order, this.subCategories});

  EventDanceCategory.fromSnapshot(var s) {
    category = s["category"];
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
      "order": order,
      "subCategories": subCategories.map((val) => val.toJson())
    };
  }
}

class DanceSubCategory {
  String subCategory;
  int order;

  DanceSubCategory({this.subCategory, this.order});

  DanceSubCategory.fromSnapshot(var s) :
        subCategory = s["subCategory"],
        order = s["order"];

  toJson() {
    return {
      "subCategory": subCategory,
      "order": order
    };
  }
}