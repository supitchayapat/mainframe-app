import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/src/model/MFEvent.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:intl/intl.dart';

final reference = FirebaseDatabase.instance.reference().child("events");

class EventDao {
  static List<MFEvent> events = <MFEvent>[];
  static List<MFEvent> future_events = <MFEvent>[];
  static List<MFEvent> past_events = <MFEvent>[];

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
      print("snapval: ${snap.value.runtimeType}");
      if(snap.value != null && snap.value.length > 0) {
        events = [];
        if(snap.value is List) {
          snap.value.forEach((val){_addEventItem(val, events);});
        }
        else {
          snap.value.forEach((key, val){_addEventItem(val, events);});
        }
      }
      _filterEvents();
      _sortEvents();
      return events;
    });
  }

  static _addEventItem(val, _eventItems) {
    var item = val;
    //print("item: ${item}");
    if(item != null) {
      MFEvent evt = new MFEvent.fromSnapshot(item);
      _eventItems.add(evt);
    }
  }

  static StreamSubscription eventsListener(Function p) {
    return reference.onValue.listen((event){
      var snap = event.snapshot;
      //print("EVT SNAP: ${event.snapshot.value}");
      future_events = <MFEvent>[];
      if(snap.value != null && snap.value.length > 0) {
        if(snap.value is List) {
          snap.value.forEach((val){_addEventItem(val, future_events);});
        }
        else {
          snap.value.forEach((key, val){_addEventItem(val, future_events);});
        }
      }

      //print("FUTURE: ${future_events.length}");

      events = [];
      _filterEvents();
      //print("AFTER FUTURE: ${future_events.length}");
      events.addAll(future_events);
      events.addAll(past_events);
      _sortEvents();
      //print("EVENTS LENGTH AFTER: ${events.length}");
      Function.apply(p, [events]);
    });
  }

  static void _filterEvents() {
    // filter date that are only future events
    future_events.removeWhere((evt){
      DateTime _now = new DateTime.now();
      //print("Date: ${evt.stopDate.toIso8601String()}");
      //print("same day: ${evt.stopDate.isAtSameMomentAs(_now)}");
      //print("before day: ${evt.stopDate.isBefore(_now)}");
      return (evt.stopDate.isAtSameMomentAs(_now) || evt.stopDate.isBefore(_now));
    });
  }

  static void _sortEvents() {
    // sort events by start date DESC
    events.sort((a, b) => (b.startDate).compareTo(a.startDate));
  }

  static Future<StreamSubscription> pastUserEventListener(Function p) {
    return userEventsListener((snap){
      past_events = <MFEvent>[];
      if(snap.value != null && snap.value.length > 0) {
        //for (Iterator iter = snap.value.iterator; iter.moveNext();) {
        snap.value.forEach((item){
          //var item = iter.current;
          //print("item: ${item}");
          if (item != null) {
            MFEvent evt = new MFEvent.fromSnapshot(item);
            past_events.add(evt);
          }
        });
      }
      events = [];
      events.addAll(past_events);
      _filterEvents();
      events.addAll(future_events);
      _sortEvents();
      Function.apply(p, [events]);
    });
  }
}