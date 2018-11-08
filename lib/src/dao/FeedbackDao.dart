import 'dart:async';
import 'dart:convert' show json;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:myapp/MFGlobals.dart' as global;

final reference = FirebaseDatabase.instance.reference().child("feedbacks");

class FeedbackDao {
  static Future saveFeedback(String msg) async {
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();

    String data = await rootBundle.loadString('mainframe_assets/conf/config.json');
    var result = json.decode(data);
    String app_version = result['app_version'];

    return reference.push().set({
      "id":fuser.uid,
      "email": fuser.email,
      "app_version" : app_version,
      "device": global.devicePlatform,
      "message": msg
    });
  }
}