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

  static Future getEventEntry() async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    return reference.child(fUser.uid).child("entry_forms");
  }
}