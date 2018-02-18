import 'package:intl/intl.dart';
import 'package:quiver/core.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:firebase_database/firebase_database.dart';

class Couple {
  String coupleName;
  List<User> couple;

  Couple({this.coupleName, this.couple});

  Couple.fromSnapshot(var s) {
    coupleName = s["coupleName"];

    if(s["couple"].length > 0) {
      couple = [];
      var _couple = s["couple"];
      //print("COUPLE TYPE: ${_couple.runtimeType}");
      _couple.forEach((val){
        couple.add(new User.fromDataSnapshot(val));
      });
    }
  }

  toJson() {
    return {
      "coupleName": coupleName,
      "couple": couple?.map((val) => val?.toJson())?.toList(),
    };
  }

  bool operator ==(o) => o is Couple && o.coupleName == coupleName && o.couple[0]?.last_name == couple[0]?.last_name && o.couple[1]?.last_name == couple[1]?.last_name;
  int get hashCode => hash2(coupleName.hashCode, couple.hashCode);
}

class Group {
  int groupNumber;
  String groupName;
  Set<User> members;

  Group({this.groupName, this.groupNumber, this.members});

  Group.fromSnapshot(var s) {
    groupNumber = s["groupNumber"];
    groupName = s["groupName"];
    if(s["members"]?.length != null && s["members"].length > 0) {
      members = new Set();
      var _members = s["members"];
      _members.forEach((member){
        members.add(new User.fromDataSnapshot(member));
      });
    }
  }

  toJson() {
    return {
      "groupName": groupName,
      "groupNumber": groupNumber,
      "members": members?.map((val) => val?.toJson())?.toList(),
    };
  }
}

class User {

  final formatter = new DateFormat("MM/dd/yyyy");

  String fbUserId;
  String stripeId;
  String first_name;
  String last_name;
  String email;
  DateTime birthday;
  Gender gender;
  DanceCategory category;
  String displayPhotoUrl;
  bool hasProfileSetup;

  User({this.fbUserId, this.first_name, this.last_name, this.email,
      this.birthday, this.gender, this.category, this.displayPhotoUrl, this.hasProfileSetup : false});

  User.fromSnapshot(DataSnapshot s) : fbUserId = s.value["facebook_userId"],
                        stripeId = s.value["stripe_custId"],
                        first_name = s.value["first_name"],
                        last_name = s.value["last_name"],
                        email = s.value["email"],
                        birthday = new DateFormat("MM/dd/yyyy").parse(s.value["birthday"]),
                        gender = getGenderFromString(s.value["gender"]),
                        category = getDanceCategoryFromString(s.value["category"]),
                        displayPhotoUrl = s.value["displayPhotoUrl"],
                        hasProfileSetup = s.value["hasProfileSetup"];

  User.fromDataSnapshot(s) : fbUserId = s["facebook_userId"],
        stripeId = s["stripe_custId"],
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

  bool operator ==(o) => o is User && o.first_name == first_name && o.last_name == last_name;
  int get hashCode => hash2(first_name.hashCode, last_name.hashCode);
}