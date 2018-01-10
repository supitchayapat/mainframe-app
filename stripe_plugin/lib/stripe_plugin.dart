import 'dart:async';

import 'package:flutter/services.dart';

class StripePlugin {
  static const MethodChannel _channel =
      const MethodChannel('stripe_plugin');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');

  static Future<String> createToken(String cardNumber, String cardExpMonth,
      String cardExpYear, String cardCVC, String stripeKey) {
    return _channel.invokeMethod("createToken", <String, String> {
      "cardNumber": cardNumber,
      "cardExpMonth": cardExpMonth,
      "cardExpYear": cardExpYear,
      "cardCVC": cardCVC,
      "stripeKey": stripeKey,
    });
  }
}
