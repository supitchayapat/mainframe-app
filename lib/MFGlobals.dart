import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:validator/validator.dart';

String FBToken = "";
FirebaseUser currentUser;
List<User> _taggableFriends = <User>[];
User dancePartner = null;

Future<List<User>> get taggableFriends async {
  if(_taggableFriends.length <= 0) {
    var subs = taggableFBFriendsListener((val){
      print("taggable list length: ${val.length}");
      val.sort((a, b) => (a.first_name).compareTo(b.first_name));
      _taggableFriends.addAll(val);
    });
    /*await getTaggableFriends().then((val) {
      print("taggable list length: ${val.length}");
      _taggableFriends.addAll(val);
    });*/
  }
  return _taggableFriends;
}

set setTaggableFriends(List<User> users) {
  _taggableFriends.addAll(users);
}

set setDancePartner(String name) {
  if(isEmail(name)) {
    dancePartner = new User(email: name);
  } else {
    String fname = "";
    String lname = "";
    if (name.contains("|")) {
      fname = (name.split("|"))[0];
      lname = (name.split("|"))[1];
    }
    else if (name.contains(" ")) {
      fname = (name.split(" "))[0];
      lname = (name.split(" "))[1];
    } else {
      fname = name;
    }
    dancePartner = new User(first_name: fname, last_name: lname);
  }
}

resetGlobal() {
  FBToken = "";
  currentUser = null;
  _taggableFriends = [];
  dancePartner = null;
}