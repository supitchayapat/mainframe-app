import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/src/model/EventEntry.dart';
import 'package:myapp/src/model/UserEvent.dart';
import 'package:myapp/src/model/MFEvent.dart';
import 'package:myapp/src/dao/EventDao.dart';
import 'package:firebase_auth/firebase_auth.dart';

final reference = FirebaseDatabase.instance.reference().child("users");

class EventEntryDao {

  static Future saveEventEntry(UserEvent userEvent) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    var pushId;
    if(userEvent.info.evtPId == null) {
      pushId = await EventDao.getEventPushId(userEvent.info.id);
    } else {
      pushId = userEvent.info.evtPId;
    }
    print("pushId: $pushId as ${pushId.runtimeType}");
    reference.child(fUser.uid).child("events").child(pushId).child("entry_forms").push().set(userEvent.usrEntryForm.toJson());
    reference.child(fUser.uid).child("events").child(pushId).child("info").set(userEvent.info.toJson());
  }

  static Future updateEventEntry(String formPushId, UserEvent userEvent) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    var pushId;
    print(userEvent.info.evtPId);
    if(userEvent.info.evtPId == null) {
      pushId = await EventDao.getEventPushId(userEvent.info.id);
    }
    else {
      pushId = userEvent.info.evtPId;
    }
    print("pushId: $pushId as ${pushId.runtimeType}");
    reference.child(fUser.uid).child("events").child(pushId).child("entry_forms").child(formPushId).set(userEvent.usrEntryForm.toJson());
    reference.child(fUser.uid).child("events").child(pushId).child("info").set(userEvent.info.toJson());
  }

  static Future<StreamSubscription> getEventEntry(evt, Function p) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    var evtPushId = evt.evtPId == null ? await EventDao.getEventPushId(evt.id) : evt.evtPId;
    print("EVT PUSHID: $evtPushId");
    return reference.child(fUser.uid).child("events").child(evtPushId).child("entry_forms")
          //.orderByChild("info/id")
          //.equalTo(eventId)
          .onValue.listen((event){
      print("ENTRY FORM: ${event.snapshot.value}");
      if(event.snapshot?.value != null) {
        Map<String, EventEntry> _evtEntries = {};
        event.snapshot.value.forEach((dataKey, dataVal) {
          //print(dataVal["levels"]);
          //print("pushId: $dataKey");
          //_evtEntries.add(new EventEntry.fromSnapshot(dataVal));
          //try {
            _evtEntries.putIfAbsent(dataKey, () => new EventEntry.fromSnapshot(dataVal));
          /*} catch(e) {
            print("EventEntryDao error: $e");
            print("snapshot: $dataVal");
          }*/
          Function.apply(p, [_evtEntries]);
        });
      }
    });
  }
}