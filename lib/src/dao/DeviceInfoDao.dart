import 'dart:async';
import 'dart:convert' show json;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:device_info/device_info.dart';
import 'package:myapp/src/model/DeviceInfo.dart';

final reference = FirebaseDatabase.instance.reference().child("device_info");

class DeviceInfoDao {
  static Future saveDeviceInfo(String status) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    DeviceInfo dInfo;
    if(global.devicePlatform == "android") {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      print('Running on ANDROID ID: ${androidInfo.id}'); // e.g. "Moto G (4)"
      dInfo = new DeviceInfo(id: androidInfo.id, model: androidInfo.model, version: androidInfo.version.release);
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
      print("Localized model: ${iosInfo.localizedModel}, System name: ${iosInfo.systemName}");
      dInfo = new DeviceInfo(id: iosInfo.identifierForVendor, model: iosInfo.model, version: "${iosInfo.systemVersion} ${iosInfo.systemName}");
    }

    dInfo.logs = [];
    DateTime _currentTimeStamp = new DateTime.now().toUtc();
    dInfo.logs.add(new DeviceLog(logMessage: status, timeStamp: _currentTimeStamp));
    dInfo.lastTimeStamp = _currentTimeStamp;
    dInfo.lastLogMessage = status;

    DatabaseReference _pushedRef = reference.push();
    //print("PUSH ID: ${_pushedRef.key}");
    await _pushedRef.set(dInfo.toJson());

    return _pushedRef.key;
  }

  static Future updateStatus(String status, {bool saveUID}) async {
    String pId = await global.getDevicePushId();
    String loginState = await global.getSharedValue("loginState");
    print("USERID IF LOGGED IN: ${global.currentUserProfile?.uid}");

    if(loginState != null && loginState == "Success") {
      print("LOGIN WAS ALREADY SUCCESSFUL. STOPPED LOGGING");
      return null;
    }

    return reference.child(pId).once().then((data){
      if(data.value != null && data.value.length > 0) {
        DeviceInfo dInfo = new DeviceInfo.fromSnapshot(data);

        DateTime _currentTimeStamp = new DateTime.now().toUtc();
        if(dInfo.logs == null) {
          dInfo.logs = [];
        }

        if(saveUID != null && saveUID) {
          if(global.currentUserProfile != null && global.currentUserProfile.uid != null)
            dInfo.uid = global.currentUserProfile.uid;
        }

        dInfo.logs.add(new DeviceLog(logMessage: status, timeStamp: _currentTimeStamp));
        dInfo.lastTimeStamp = _currentTimeStamp;
        dInfo.lastLogMessage = status;

        return reference.child(pId).set(dInfo.toJson());
      } else {
        // There's no existing data even though push ID is already set
        return saveDeviceInfo(status).then((pushId){
           return global.setDevicePushId(pushId);
        });
      }
    });
  }
}