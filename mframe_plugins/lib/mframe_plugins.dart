import 'dart:async';

import 'package:flutter/services.dart';

class UserContactInfo {
  String contactName;
  String contactPhone;
  
  UserContactInfo({this.contactName, this.contactPhone});
}

class MframePlugins {
  static const MethodChannel _channel =
      const MethodChannel('mframe_plugins');

  static Future<List<UserContactInfo>> phoneContacts() async {
    List<UserContactInfo> _contacts = [];
    final Map<String, dynamic> data = await _channel.invokeMethod('getContacts');
    print("data: "+data.toString());
    if(data != null && data.isNotEmpty && data["contacts"].length > 0) {
      for(Map<String, dynamic> contact in data["contacts"]) {
        _contacts.add(new UserContactInfo(contactName: contact["name"], contactPhone: contact["phoneNumber"]));
      }
    }
    return _contacts;
  }

  static void setToLandscape() {
    _channel.invokeMethod('setLandscape');
  }

  static void setToPortrait() {
    _channel.invokeMethod('setPortrait');
  }
}
