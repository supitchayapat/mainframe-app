import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/dao/UserDao.dart';

String FBToken = "";
FirebaseUser currentUser;
List<User> _taggableFriends = <User>[];
User dancePartner = null;

Future<List<User>> get taggableFriends async {
  await getTaggableFriends().then((val) {
    _taggableFriends.addAll(val);
  });
  return _taggableFriends;
}

set setTaggableFriends(List<User> users) {
  _taggableFriends.addAll(users);
}

set setDancePartner(String name) {
  String fname = "";
  String lname = "";
  if(name.contains(" ")) {
    fname = (name.split(" "))[0];
    lname = (name.split(" "))[1];
  } else {
    fname = name;
  }
  dancePartner = new User(first_name: fname, last_name: lname);
}