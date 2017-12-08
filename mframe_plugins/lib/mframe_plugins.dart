import 'dart:async';

import 'package:flutter/services.dart';

class MframePlugins {
  static const MethodChannel _channel =
      const MethodChannel('mframe_plugins');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
}
