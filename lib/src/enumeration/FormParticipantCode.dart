enum FormParticipantCode {
  SOLO_GIRL, SOLO_GUY, POLO_GIRL, POLO_GUY,
  PROAM_GUY, PROAM_GIRL, AM, AM_GIRL, AM_GUY,
  PRO, PRO_GIRL, PRO_GUY, GROUP, ASST_GUY, ASST_GIRL
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