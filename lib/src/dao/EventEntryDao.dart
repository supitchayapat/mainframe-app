import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/src/model/EventEntry.dart';
import 'package:firebase_auth/firebase_auth.dart';

final reference = FirebaseDatabase.instance.reference().child("users");

class EventEntryDao {

  static saveEventEntry(EventEntry entry) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    reference.child(fUser.uid).child("entry_forms").push().set(entry.toJson());
  }

  static updateEventEntry(String pushId, EventEntry entry) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    reference.child(fUser.uid).child("entry_forms").child(pushId).set(entry.toJson());
  }

  static Future<StreamSubscription> getEventEntry(competitionId, Function p) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    return reference.child(fUser.uid).child("entry_forms")
          .orderByChild("event/competitionId")
          .equalTo(competitionId)
          .onValue.listen((event){
      //print(event.snapshot.value);
      if(event.snapshot?.value != null) {
        Map<String, EventEntry> _evtEntries = {};
        event.snapshot.value.forEach((dataKey, dataVal) {
          //print(dataVal["levels"]);
          //print("pushId: $dataKey");
          //_evtEntries.add(new EventEntry.fromSnapshot(dataVal));
          try {
            _evtEntries.putIfAbsent(dataKey, () => new EventEntry.fromSnapshot(dataVal));
          } catch(e) {
            print("EventEntryDao error: $e");
            print("snapshot: $dataVal");
          }
          Function.apply(p, [_evtEntries]);
        });
      }
    });
  }
}