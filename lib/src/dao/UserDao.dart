import 'dart:convert';
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:facebook_sign_in/facebook_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:intl/intl.dart';

final reference = FirebaseDatabase.instance.reference().child("users");
final taggableRef = FirebaseDatabase.instance.reference().child("users");
final partnerRef = FirebaseDatabase.instance.reference().child("users");

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
  reference.child(fbaseUser.uid).child("info").set(user.toJson());
}

Future userExists(FirebaseUser user) {
  return reference.child(user.uid).child("info").once().then((DataSnapshot data) {
    if(data.value != null && data.value.length > 0) {
      return new User.fromSnapshot(data);
    }
    else {
      return null;
    }
  });
}

Future userExistsByEmail(String email) {
  return reference.orderByChild("email").equalTo(email).once().then((data){
    User usr = null;
    if(data.value != null && data.value.length > 0) {
      data.value.forEach((k, val) {
        usr = new User.fromDataSnapshot(val);
      });
    }
    return usr;
  });
}

Future saveUser(User usr) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("info").set(usr.toJson());
}

Future saveUserFromFirebase(FirebaseUser usr) async {
  User user = new User(fbUserId: "", first_name: "", last_name: "", email: usr.email, birthday: new DateTime.now(), displayPhotoUrl: usr.photoUrl);
  return reference.child(usr.uid).child("info").set(user.toJson());
}

Future saveUserAccessToken(String token) async {
  //final _ref = FirebaseDatabase.instance.reference().child("fb_tokens");
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("fb_tokens").set({"fbToken": token});
}

Future<StreamSubscription> savedUserListener(Function p) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("info").onValue.listen((event){
    if(event.snapshot.value != null) {
      Function.apply(p, [event]);
    }
  });
}

Future<StreamSubscription> deleteUserListener(Function p) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).onChildRemoved.listen((event){
    if(event.snapshot.value != null) {
      Function.apply(p, [event]);
    }
  });
}

Future<User> getCurrentUserProfile() async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("info").once().then((DataSnapshot data) {
    //print(data.value["first_name"]);
    print(data.value);
    return new User.fromSnapshot(data);
  });
}

Future<dynamic> saveUserFriends(List<User> users) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return taggableRef.child(fuser.uid).child("taggable_friends").push().set(
    users.map((val){
      return val.toJson();
    }).toList()
  );
}

Future saveUserExistingParticipants(User user) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  User _existingUser = await getUserDanceParticipantViaName(user);
  if(_existingUser != null) {
    print("User ${user.first_name} ${user.last_name} exists");
    return _existingUser;
  }

  return partnerRef.child(fuser.uid).child("existing_participants").push().set(user.toJson());
}

Future<dynamic> saveUserSoloParticipants(User user) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  User _existingUser = await getUserSoloParticipantViaName(user);
  if(_existingUser != null) {
    print("User ${user.first_name} ${user.last_name} exists");
    return _existingUser;
  }

  return partnerRef.child(fuser.uid).child("solo_participants").push().set(user.toJson());
}

Future<User> getUserSoloParticipantViaName(User user) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return partnerRef.child(fuser.uid).child("solo_participants").orderByChild("first_name").equalTo(user.first_name).once().then((data){
    User _retVal = null;
    if(data.value != null && data.value.length > 0) {
      data.value.forEach((dataKey, dataVal) {
        User dataUser = new User.fromDataSnapshot(dataVal);
        if(dataUser.last_name == user.last_name) {
          _retVal = dataUser;
        }
      });
    }
    return _retVal;
  });
}

Future<User> getUserDanceParticipantViaName(User user) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return partnerRef.child(fuser.uid).child("existing_participants").orderByChild("first_name").equalTo(user.first_name).once().then((data){
    User _retVal = null;
    if(data.value != null && data.value.length > 0) {
      data.value.forEach((dataKey, dataVal) {
        User dataUser = new User.fromDataSnapshot(dataVal);
        if(dataUser.last_name == user.last_name) {
          _retVal = dataUser;
        }
      });
    }
    return _retVal;
  });
}

Future getUserExistingParticipants() async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return partnerRef.child(fuser.uid).child("existing_participants").once().then((data){
    List<User> _users = <User>[];
    if(data.value != null && data.value.length > 0) {
      data.value.forEach((dataKey, dataVal) {
        _users.add(new User.fromDataSnapshot(dataVal));
      });
      _users.sort((a, b) => (a.first_name).compareTo(b.first_name));
    }
    return _users;
  });
}

Future<String> getFBAccessToken() async {
  return await FacebookSignIn.getToken();
}

Future<StreamSubscription> userEventsListener(Function p) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("events").onValue.listen((event){
    if(event.snapshot != null) {
      var _events = event.snapshot;
      Function.apply(p, [_events]);
    }
  });
}

Future<StreamSubscription> taggableFBFriendsListener(Function p) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return taggableRef.child(fuser.uid).child("taggable_friends").onValue.listen((event){
    List<User> _users = <User>[];
    if(event.snapshot.value != null) {
      print("snap length: ${event.snapshot.value.length}");
      event.snapshot.value.forEach((key, dataVal) {
        _users.add(new User.fromDataSnapshot(dataVal));
      });
      Function.apply(p, [_users]);
    }
  });
}

Future<List<User>> getTaggableFriends() async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return taggableRef.child(fuser.uid).child("taggable_friends").once().then((DataSnapshot data){
    List<User> _users = <User>[];
    print("snapshot length: ${data.value.length} anchor key: ${data.key}");
    data.value.forEach((key, dataVal){
      print("key: $key");
      _users.add(new User.fromDataSnapshot(dataVal));
    });

    _users.sort((a, b) => (a.first_name).compareTo(b.first_name));
    return _users;
  });
}

Future<StreamSubscription> soloParticipantsListener(Function p) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("solo_participants").onValue.listen((event){
    if(event.snapshot.value != null && event.snapshot.value.length > 0) {
      List<User> _users = <User>[];
      var _snapshot = event.snapshot;
      _snapshot.value.forEach((key, dataVal){
        _users.add(new User.fromDataSnapshot(dataVal));
      });
      _users.sort((a, b) => (a.first_name).compareTo(b.first_name));
      Function.apply(p, [_users]);
    }
  });
}

Future<void> removeSoloParticipant(User user) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return partnerRef.child(fuser.uid).child("solo_participants").once().then((_snapshot){
    if(_snapshot.value != null && _snapshot.value.length > 0) {
      var keyId;
      _snapshot.value.forEach((key, dataVal){
        User _userSnap = new User.fromDataSnapshot(dataVal);
        if(_userSnap == user) {
          keyId = key;
        }
      });
      if(keyId != null)
        return partnerRef.child(fuser.uid).child("solo_participants")
            .child(keyId).set(null);
    }
  });
}

Future<StreamSubscription> coupleParticipantsListener(Function p) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return reference.child(fuser.uid).child("couple_participants").onValue.listen((event){
    if(event.snapshot.value != null && event.snapshot.value.length > 0) {
      List<Couple> _couples = <Couple>[];
      var _snapshot = event.snapshot;
      //print("SNAP TYPE: ${_snapshot.value.runtimeType}");
      _snapshot.value.forEach((key, dataVal){
        _couples.add(new Couple.fromSnapshot(dataVal));
      });
      _couples.sort((a, b) => (a.coupleName).compareTo(b.coupleName));
      Function.apply(p, [_couples]);
    }
  });
}

Future<User> getUserCoupleParticipants(User user) async {
  print("GET COUPLES");
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return partnerRef.child(fuser.uid).child("couple_participants").once().then((data){
    print("data: $data");
    //return _retVal;
  });
}

Future<dynamic> saveUserCoupleParticipants(User user, User user2) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return partnerRef.child(fuser.uid).child("couple_participants").once().then((_snapshot){
    if(_snapshot.value != null && _snapshot.value.length > 0) {
      Couple couple = null;
      _snapshot.value.forEach((key, dataVal){
        Couple coupleSnap = new Couple.fromSnapshot(dataVal);
        //print(couple.coupleName);
        //print((coupleSnap.couple.contains(user) && coupleSnap.couple.contains(user2)));
        if((coupleSnap.couple.contains(user) && coupleSnap.couple.contains(user2))) {
          //print("COUPLE EXISTS");
          couple = coupleSnap;
        }
      });
      if(couple == null) {
        couple = new Couple(
            coupleName: "${user.first_name} & ${user2.first_name}",
            couple: [user, user2]);
        return partnerRef.child(fuser.uid).child("couple_participants")
            .push()
            .set(couple.toJson()).then((_val){
          return couple;
        });
      }
    } else {
      Couple couple = new Couple(coupleName: "${user.first_name} & ${user2.first_name}", couple: [user, user2]);
      return partnerRef.child(fuser.uid).child("couple_participants").push().set(couple.toJson()).then((_val){
        return couple;
      });
    }
  });
}

Future<void> removeUserCoupleParticipants(User user, User user2) async {
  FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
  return partnerRef.child(fuser.uid).child("couple_participants").once().then((_snapshot){
    if(_snapshot.value != null && _snapshot.value.length > 0) {
      Couple couple = null;
      var keyId;
      _snapshot.value.forEach((key, dataVal){
        Couple coupleSnap = new Couple.fromSnapshot(dataVal);
        //print(couple.coupleName);
        //print((coupleSnap.couple.contains(user) && coupleSnap.couple.contains(user2)));
        if((coupleSnap.couple.contains(user) && coupleSnap.couple.contains(user2))) {
          //print("COUPLE EXISTS");
          couple = coupleSnap;
          keyId = key;
        }
      });
      if(couple != null) {
        return partnerRef.child(fuser.uid).child("couple_participants")
            .child(keyId).set(null);
      }
    }
  });
}