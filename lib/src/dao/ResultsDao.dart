import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/HeatResult.dart';

final reference = FirebaseDatabase.instance.reference().child("users");

class ResultsDao {
  static Future getResults(evtPushId) async {
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
    return reference.child(fuser.uid).child("events").child(evtPushId).child("results")
      .child("program")
      .once().then((data){
        if(data.value != null && data.value.length > 0) {
          return new HeatResult.fromSnapshot(data);
        }
        else {
          return null;
        }
    });
  }
}