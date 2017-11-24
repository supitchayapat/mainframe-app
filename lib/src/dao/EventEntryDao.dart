import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/src/model/EventEntry.dart';
import 'package:firebase_auth/firebase_auth.dart';

final reference = FirebaseDatabase.instance.reference().child("entries");

class EventEntryDao {

  static saveEventEntry(EventEntry entry) async {
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    reference.child(fUser.uid).set(entry.toJson());
  }
}