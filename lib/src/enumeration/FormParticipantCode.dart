enum FormParticipantCode {
  SOLO_GIRL, SOLO_GUY, PROAM_GUY, PROAM_GIRL, AMATEUR, AM_AM, GROUP
}

FormParticipantCode getParticipantCodeFromString(String code) {
  code = 'FormParticipantCode.${code.replaceAll("-", "_")}';
  try {
    return FormParticipantCode.values.firstWhere((f)=> f.toString() == code);
  } catch (e) {
    // If there is no Category, it will throw "Bad state: No element"
    return null;
  }
}