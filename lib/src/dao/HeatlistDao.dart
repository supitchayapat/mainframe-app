import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/Heat.dart';

final reference = FirebaseDatabase.instance.reference().child("users");

class HeatListDao {
  static Future getHeats(evtPushId) async {
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
    return reference.child(fuser.uid).child("events").child(evtPushId).child("heatlist")
        .child("program")
        .once().then((data){
      if(data.value != null && data.value.length > 0) {
        return new Heat.fromSnapshot(data);
      }
      else {
        return null;
      }
    });
  }
}