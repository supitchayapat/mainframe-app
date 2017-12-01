import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/dao/UserDao.dart';

String FBToken = "";
FirebaseUser currentUser;
List<User> _taggableFriends = <User>[];

Future<List<User>> get taggableFriends async {
  await getTaggableFriends().then((val) {
    _taggableFriends.addAll(val);
  });
  return _taggableFriends;
}

set setTaggableFriends(List<User> users) {
  _taggableFriends.addAll(users);
}