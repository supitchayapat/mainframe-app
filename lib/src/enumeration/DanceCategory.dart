enum DanceCategory {
  PROFESSIONAL, AMATEUR
}

DanceCategory getDanceCategoryFromString(String category) {
  category = 'DanceCategory.$category';
  try {
    return DanceCategory.values.firstWhere((f)=> f.toString() == category);
  } catch (e) {
    // If there is no Category, it will throw "Bad state: No element"
    return null;
  }
}