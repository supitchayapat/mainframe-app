enum FormType {
  STANDARD, SOLO, GROUP
}

FormType getFormTypeFromString(String category) {
  category = 'FormType.$category';
  try {
    return FormType.values.firstWhere((f)=> f.toString() == category);
  } catch (e) {
    // If there is no Category, it will throw "Bad state: No element"
    return null;
  }
}