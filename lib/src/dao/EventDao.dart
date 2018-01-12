import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/src/model/MFEvent.dart';
import 'package:intl/intl.dart';

final reference = FirebaseDatabase.instance.reference().child("events");

class EventDao {
  static List<MFEvent> events = <MFEvent>[];

  static Future<List<MFEvent>> getEvents() async {
    /*if(evt_listener == null) {
      evt_listener = reference.onValue.listen((event) {
        //print(event.snapshot.value);
      });
    }*/
    //reference.keepSynced(true);

    if(events.length > 0) {
      return events;
    }

    return reference.once().then((snap) {
      //print("snapval: ${snap.value.length}");
      for(Iterator iter=snap.value.iterator; iter.moveNext();) {
        var item = iter.current;
        //print("item: ${item}");
        if(item != null) {
          MFEvent evt = new MFEvent.fromSnapshot(item);
          events.add(evt);
        }
      }
      _filterEvents();
      return events;
    });
  }

  static StreamSubscription eventsListener(Function p) {
    return reference.onValue.listen((event){
      var snap = event.snapshot;
      events = <MFEvent>[];
      for(Iterator iter=snap.value.iterator; iter.moveNext();) {
        var item = iter.current;
        //print("item: ${item}");
        if(item != null) {
          MFEvent evt = new MFEvent.fromSnapshot(item);
          events.add(evt);
        }
      }
      _filterEvents();
      Function.apply(p, [events]);
    });
  }

  static void _filterEvents() {
    // filter date that are only future events
    events.removeWhere((evt){
      DateTime _now = new DateTime.now();
      //print("Date: ${evt.stopDate.toIso8601String()}");
      //print("same day: ${evt.stopDate.isAtSameMomentAs(_now)}");
      //print("before day: ${evt.stopDate.isBefore(_now)}");
      return (evt.stopDate.isAtSameMomentAs(_now) || evt.stopDate.isBefore(_now));
    });
    // sort events by start date DESC
    events.sort((a, b) => (a.startDate).compareTo(b.startDate));
  }
}