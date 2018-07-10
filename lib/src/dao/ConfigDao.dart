import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

final reference = FirebaseDatabase.instance.reference().child("configuration");

class ConfigDao {

  static Future getAOFlag() async {
    return reference.child("ao_flag").once().then((DataSnapshot data){
      if(data?.value != null) {
        if(data.value is String) {
          return data.value.toString().toLowerCase() == 'true';
        } else {
          return data.value;
        }
      } else {
        return null;
      }
    });
  }
}