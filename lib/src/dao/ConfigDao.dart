import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/MFGlobals.dart' as global;

final reference = FirebaseDatabase.instance.reference().child("configuration").child("public");

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

  static Future getSupportEmail() async {
    String configKey = "ios_support_email";
    if(global.devicePlatform == "android") {
      configKey = "android_support_email";
    }

    return reference.child(configKey).once().then((DataSnapshot data){
      if(data?.value != null) {
        return data.value;
      } else {
        return "";
      }
    });
  }

  static Future getMinVersion() async {
    return reference.child("minimum_version").once().then((DataSnapshot data){
      if(data?.value != null) {
        return data.value;
      } else {
        return null;
      }
    });
  }
}