import 'dart:convert';
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:facebook_sign_in/facebook_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:intl/intl.dart';

final reference = FirebaseDatabase.instance.reference().child("users");


User convertResponseToUser(json_usr) {
  final formatter = new DateFormat("MM/dd/yyyy");
  return new User(json_usr["id"], json_usr["first_name"], json_usr["last_name"], null,
      json_usr["birthday"] != null ? formatter.parse(json_usr["birthday"]) : null,
      getGenderFromString(json_usr["gender"].toString().toUpperCase()),
      null, null);
}

void saveUserFromResponse(var response, FirebaseUser fbaseUser) {
  final json_usr = JSON.decode(response);
  User user = convertResponseToUser(json_usr);
  print('SAVING USER FROM RESPONSE....');
  user.displayPhotoUrl = fbaseUser.photoUrl;
  user.email = fbaseUser.email;
  print(user.toJson());
  reference.child(fbaseUser.uid).set(user.toJson());
}

Future userExists(FirebaseUser user) {
  return reference.child(user.uid).once().then((DataSnapshot data) {
    return new User.fromSnapshot(data);
  });
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

Future<User> saveUserFriends(List<User> users) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("taggable_fb_friends").set(
    users.map((val){
      return val.toJson();
    }).toList()
  );
}

Future<String> getFBAccessToken() async {
  return await FacebookSignIn.getToken();
}

Future<StreamSubscription> taggableFBFriendsListener(Function p) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("taggable_fb_friends").limitToFirst(10).onChildAdded.listen((event){
    Function.apply(p, [new User.fromSnapshot(event.snapshot)]);
  });
}