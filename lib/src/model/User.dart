import 'package:intl/intl.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:firebase_database/firebase_database.dart';

class User {

  final formatter = new DateFormat("MM/dd/yyyy");

  String fbUserId;
  String first_name;
  String last_name;
  String email;
  DateTime birthday;
  Gender gender;
  DanceCategory category;
  String displayPhotoUrl;
  bool hasProfileSetup;

  User(this.fbUserId, this.first_name, this.last_name, this.email,
      this.birthday, this.gender, this.category, this.displayPhotoUrl, {this.hasProfileSetup : false});

  User.fromSnapshot(DataSnapshot s) : fbUserId = s.value["facebook_userId"],
                        first_name = s.value["first_name"],
                        last_name = s.value["last_name"],
                        email = s.value["email"],
                        birthday = new DateFormat("MM/dd/yyyy").parse(s.value["birthday"]),
                        gender = getGenderFromString(s.value["gender"]),
                        category = getDanceCategoryFromString(s.value["category"]),
                        displayPhotoUrl = s.value["displayPhotoUrl"],
                        hasProfileSetup = s.value["hasProfileSetup"];

  User.fromDataSnapshot(s) : fbUserId = s["facebook_userId"],
        first_name = s["first_name"],
        last_name = s["last_name"],
        email = s["email"],
        birthday = new DateFormat("MM/dd/yyyy").parse(s["birthday"]),
        gender = getGenderFromString(s["gender"]),
        category = getDanceCategoryFromString(s["category"]),
        displayPhotoUrl = s["displayPhotoUrl"],
        hasProfileSetup = s["hasProfileSetup"];


  toJson() {
    return {
      "facebook_userId": fbUserId,
      "first_name": first_name,
      "last_name": last_name,
      "email": email,
      "birthday": birthday!= null ? formatter.format(birthday) : formatter.format(new DateTime.now()),
      "gender": gender != null ? gender.toString().replaceAll("Gender.", "") : null,
      "category": category != null ? category.toString().replaceAll("DanceCategory.", "") : null,
      "displayPhotoUrl": displayPhotoUrl,
      "hasProfileSetup": hasProfileSetup
    };
  }
}