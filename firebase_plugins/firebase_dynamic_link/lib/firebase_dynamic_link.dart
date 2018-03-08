import 'dart:async';

import 'package:flutter/services.dart';

class FirebaseDynamicLink {
  static const MethodChannel _channel =
      const MethodChannel('firebase_dynamic_link');

  static Future<String> getDynamicLink() async {
    return await _channel.invokeMethod('getDynamicLink');
  }
}
