import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/src/model/MFEvent.dart';

final reference = FirebaseDatabase.instance.reference().child("events");

class EventDao {

  static Future<List<MFEvent>> getEvents() {
    reference.onValue.listen((event){
      //print(event.snapshot.value);
    });
    //reference.keepSynced(true);
    List<MFEvent> events = <MFEvent>[];
    return reference.once().then((snap) {
      for(Iterator iter=snap.value.iterator; iter.moveNext();) {
        var item = iter.current;
        MFEvent evt = new MFEvent.fromSnapshot(item);
        events.add(evt);
      }
      return events;
    });
  }
}