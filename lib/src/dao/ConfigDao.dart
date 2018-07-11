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

  static Future<StreamSubscription> aoFlagListener(Function p) async {
    return reference.child("ao_flag").onValue.listen((Event event){
      DataSnapshot data = event.snapshot;
      if(data?.value != null) {
        if(data.value is String) {
          Function.apply(p, [data.value.toString().toLowerCase() == 'true']);
        } else {
          Function.apply(p, [data.value]);
        }
      } else {
        Function.apply(p, [null]);
      }
    });
  }
}