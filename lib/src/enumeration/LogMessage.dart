enum LogMessage {
  APP_LOADED, CLICKED_LOGIN, SUCCESSFUL_LOGIN
}

LogMessage getFormTypeFromString(String category) {
  category = 'FormType.$category';
  try {
    return LogMessage.values.firstWhere((f)=> f.toString() == category);
  } catch (e) {
    // If there is no Category, it will throw "Bad state: No element"
    return null;
  }
}

String toStringForm() {
  return null;
}