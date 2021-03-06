import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:validator/validator.dart';
import 'package:myapp/src/model/MFEvent.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/src/dao/ConfigDao.dart';

String FBToken = "";
FirebaseUser currentUser;
User currentUserProfile;
List<User> _taggableFriends = <User>[];
User dancePartner = null;
List<MFEvent> events = <MFEvent>[];
bool hasTips = true;
String devicePlatform = "";
String app_version = "";
String conf_version = "";
List<String> messageLogs = <String>[];
bool aoFlag;
bool testUserFlag = false;

FirebaseAnalytics analytics;
FirebaseAnalyticsObserver observer;

Future<List<User>> get taggableFriends async {
  if(_taggableFriends.length <= 0) {
    var subs = taggableFBFriendsListener((val){
      print("taggable list length: ${val.length}");
      if(val != null && val.length > 0) {
        _taggableFriends = [];
        val.sort((User a, User b) => (a.first_name).compareTo(b.first_name));
        _taggableFriends.addAll(val);
      }
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

Future setDevicePushId(String pushId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("pushId", pushId);
  print("PUSH ID SET: ${pushId}");
}

Future getDevicePushId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("GET PUSH ID = ${prefs.getString("pushId")}");
  return prefs.getString("pushId");
}

Future setSharedValue(String key, String sharedVal) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, sharedVal);
  print("${key} SET: ${sharedVal}");
}

Future getSharedValue(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String sharedVal = prefs.getString(key);
  print("${key} GET: ${sharedVal}");
  return sharedVal;
}

resetGlobal() {
  FBToken = "";
  currentUser = null;
  _taggableFriends = [];
  dancePartner = null;
  testUserFlag = false;
}