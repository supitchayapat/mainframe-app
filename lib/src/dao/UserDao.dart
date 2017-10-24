import 'dart:convert';
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:intl/intl.dart';

final reference = FirebaseDatabase.instance.reference().child("users");

User convertResponseToUser(var response) {
  final json_usr = JSON.decode(response);
  final formatter = new DateFormat("MM/dd/yyyy");
  return new User(json_usr["id"], json_usr["first_name"], json_usr["last_name"], null,
      formatter.parse(json_usr["birthday"]),
      getGenderFromString(json_usr["gender"].toString().toUpperCase()),
      null, null);
}

void saveUserFromResponse(var response, FirebaseUser fbaseUser) {
  User user = convertResponseToUser(response);
  user.displayPhotoUrl = fbaseUser.photoUrl;
  user.email = fbaseUser.email;
  reference.child(fbaseUser.uid).set(user.toJson());
}

Future<User> saveUser(User usr) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).set(usr.toJson());
}

Future<User> saveUserFromFirebase(FirebaseUser usr) async {
  User user = new User("", "", "", usr.email, new DateTime.now(), null, null, usr.photoUrl);
  return reference.child(usr.uid).set(user.toJson());
}

Future<User> getCurrentUserProfile() async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).once().then((DataSnapshot data) {
    return new User.fromSnapshot(data);
  });
}