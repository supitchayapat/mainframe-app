import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/src/model/MFEvent.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/util/PerformanceUtil.dart';
import 'package:myapp/MFGlobals.dart' as global;

final reference = FirebaseDatabase.instance.reference().child("events");

class EventDao {
  static List<MFEvent> future_events = <MFEvent>[];
  static List<MFEvent> past_events = <MFEvent>[];

  static Future<MFEvent> getEvent(eventId) async {
    return getEvents().then((_evnts){
      if(_evnts.length > 0) {
        for(var _evt in _evnts) {
          if(_evt.id == eventId) {
            return _evt;
          }
        }
      }
    });
  }

  static Future<List<MFEvent>> getEvents() async {
    /*if(evt_listener == null) {
      evt_listener = reference.onValue.listen((event) {
        //print(event.snapshot.value);
      });
    }*/
    //reference.keepSynced(true);

    if(global.events.length > 0) {
      return global.events;
    }

    return reference.once().then((snap) {
      print("snapval: ${snap.value.runtimeType}");
      if(snap.value != null && snap.value.length > 0) {
        global.events = [];
        if(snap.value is List) {
          snap.value.forEach((val){_addEventItem(val, global.events);});
        }
        else {
          snap.value.forEach((key, val){_addEventItem(val, global.events, key: key);});
        }
      }
      _filterEvents();
      _sortEvents();
      return global.events;
    });
  }

  static _addEventItem(val, _eventItems, {key}) {
    var item = val;
    //print("item: ${item}");
    if(item != null) {
      MFEvent evt = new MFEvent.fromSnapshot(item);
      evt.evtPId = key != null ? key : null;
      _eventItems.add(evt);
    }
  }

  static StreamSubscription eventsListener(Function p) {
    return reference.onValue.listen((event){
      var snap = event.snapshot;
      print("EVT SNAP: ${event.snapshot.value.length}");
      future_events = <MFEvent>[];
      if(snap.value != null && snap.value.length > 0) {
        if(snap.value is List) {
          snap.value.forEach((val){
            //print("val: ${val}");
            _addEventItem(val, future_events);
          });
        }
        else {
          snap.value.forEach((key, val){
            //print("key: ${key} val: ${val}");
            _addEventItem(val, future_events, key: key);
          });
        }
      }

      print("FUTURE EVTS: ${future_events.length}");

      global.events = [];
      _filterEvents();
      //print("AFTER FUTURE: ${future_events.length}");
      global.events.addAll(future_events);
      //global.events.addAll(past_events);
      _sortEvents();
      //print("EVENTS LENGTH AFTER: ${events.length}");
      Function.apply(p, [global.events]);
    });
  }

  static void _filterEvents() {
    // filter date that are only future events
    future_events.removeWhere((evt){
      DateTime _now = new DateTime.now();
      //print("Date: ${evt.stopDate.toIso8601String()}");
      //print("same day: ${evt.stopDate.isAtSameMomentAs(_now)}");
      //print("before day: ${evt.stopDate.isBefore(_now)}");
      return (evt.dateStop.isAtSameMomentAs(_now) || evt.dateStop.isBefore(_now));
    });
  }

  static void _sortEvents() {
    // sort events by start date DESC
    global.events.sort((a, b) => (a.dateStart).compareTo(b.dateStart));
  }

  static Future<StreamSubscription> pastUserEventListener(Function p) {
    return userEventsListener((snap){
      past_events = <MFEvent>[];
      DateTime _now = new DateTime.now();
      if(snap.value != null && snap.value.length > 0) {
        snap.value.forEach((key, item){
          //print("item: ${item}");
          if (item != null) {
            MFEvent evt = new MFEvent.userSnapshot(item);
            evt.evtPId = key != null ? key : null;
            // check if past event qualifies:
            // 1. check results node if exists
            // 2. check stop date is before current date
            if(evt.results != null && evt.dateStop.isBefore(_now)) {
              past_events.add(evt);
            }
          }
        });
      }
      print("PAST EVTS: ${past_events.length}");
      //global.events = [];
      //global.events.addAll(past_events);
      //_filterEvents();
      //global.events.addAll(future_events);
      past_events.sort((a, b) => (a.dateStart).compareTo(b.dateStart));
      Function.apply(p, [past_events]);
    });
  }

  static Future getEventPushId(eventId) async {
    dynamic returnVal;
    await reference.once().then((snap) async {
      if(snap.value != null && snap.value.length > 0) {
        global.events = [];
        if(snap.value is List) {
          int ctr = 1;
          snap.value.forEach((val){
            MFEvent evt = new MFEvent.fromSnapshot(val);
            if(evt.id == eventId) {
              //print("${evt.eventTitle} ID: $ctr");
              returnVal = ctr;
            }
            ctr++;
          });
        }
        else {
          snap.value.forEach((key, val){
            MFEvent evt = new MFEvent.fromSnapshot(val);
            if(evt.id == eventId) {
              //print("${evt.eventTitle} ID: $key");
              returnVal = key;
            }
          });
        }
      }
    });
    return returnVal;
  }

  static Future<StreamSubscription> removeEventListener(Function p) async {
    return reference
        .onChildRemoved
        .listen((event) {
      print("deleted event");
      var val = event.snapshot.value;
      print(val);
      MFEvent evt = new MFEvent.fromSnapshot(val);
      Function.apply(p, [evt]);
    });
  }
}