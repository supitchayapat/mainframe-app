enum Gender {
  MAN, WOMAN
}

Gender getGenderFromString(String gender) {
  gender = 'Gender.$gender';
  try {
    return Gender.values.firstWhere((f)=> f.toString() == gender);
  } catch (e) {
    // If there is no gender, it will throw "Bad state: No element"
    return null;
  }
}