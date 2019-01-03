import 'dart:async';
import 'dart:convert' show json;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/MFGlobals.dart' as global;

final reference = FirebaseDatabase.instance.reference().child("admin_notification");

class AdminNotification {

  static Future sendNotification(String message) async {
    final formatterSrc = new DateFormat("yyyy-MM-dd HH:mm:ss");
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();

    String data = await rootBundle.loadString('mainframe_assets/conf/config.json');
    var result = json.decode(data);
    String app_version = result['app_version'];
    DateTime dt = new DateTime.now().toUtc();

    return reference.push().set({
      "id":fuser.uid,
      "email": fuser.email,
      "app_version" : app_version,
      "device": global.devicePlatform,
      "dateSubmitted": formatterSrc.format(dt),
      "message": message
    });
  }
}