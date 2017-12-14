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
  return new User(fbUserId: json_usr["id"], first_name: json_usr["first_name"], last_name: json_usr["last_name"],
      birthday: json_usr["birthday"] != null ? formatter.parse(json_usr["birthday"]) : null,
      gender: getGenderFromString(json_usr["gender"].toString().toUpperCase()));
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

Future userExistsByEmail(String email) {
  return reference.orderByChild("email").equalTo(email).once().then((data){
    User usr = null;
    data.value.forEach((k, val){
      usr = new User.fromDataSnapshot(val);
    });
    return usr;
  });
}

Future<User> saveUser(User usr) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).set(usr.toJson());
}

Future<User> saveUserFromFirebase(FirebaseUser usr) async {
  User user = new User(fbUserId: "", first_name: "", last_name: "", email: usr.email, birthday: new DateTime.now(), displayPhotoUrl: usr.photoUrl);
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

Future<User> saveUserDancePartner(User user) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("dance_partners").push().set(user.toJson());
}

Future getUserExistingDancePartners() async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("dance_partners").once().then((data){
    print(data.value);
    List<User> _users = <User>[];
    data.value.forEach((dataKey, dataVal){
      _users.add(new User.fromDataSnapshot(dataVal));
    });
    _users.sort((a, b) => (a.first_name).compareTo(b.first_name));
    return _users;
  });
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

Future<List<User>> getTaggableFriends() async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("taggable_fb_friends").once().then((DataSnapshot data){
    List<User> _users = <User>[];
    data.value.forEach((dataVal){
      _users.add(new User.fromDataSnapshot(dataVal));
    });
    return _users;
  });
}