enum FormParticipantType {
  SOLO, COUPLE, GROUP
}

FormParticipantType getParticipantTypeFromString(String type) {
  type = 'FormParticipantType.$type';
  try {
    return FormParticipantType.values.firstWhere((f)=> f.toString() == type);
  } catch (e) {
    // If there is no gender, it will throw "Bad state: No element"
    return null;
  }
}