import 'dart:async';

import 'package:flutter/services.dart';

class StripeCard {
  String tokenId;
  String brand;
  String last4;

  StripeCard({this.tokenId, this.brand, this.last4});

  StripeCard.fromSnapshot(var s) {
    tokenId = s["token"];
    brand = s["brand"];
    last4 = s["lastdigits"];
  }

  StripeCard.fromDataSnapshot(var s) {
    tokenId = s["tokenId"];
    brand = s["brand"];
    last4 = s["last4"];
  }

  toJson() {
    return {
      "tokenId": tokenId,
      "brand": brand,
      "last4": last4
    };
  }
}

class StripePlugin {
  static const MethodChannel _channel =
      const MethodChannel('stripe_plugin');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');

  static Future<StripeCard> createToken(String cardNumber, String cardExpMonth,
      String cardExpYear, String cardCVC, String stripeKey) {
    return _channel.invokeMethod("createToken", <String, String> {
      "cardNumber": cardNumber,
      "cardExpMonth": cardExpMonth,
      "cardExpYear": cardExpYear,
      "cardCVC": cardCVC,
      "stripeKey": stripeKey,
    }).then((card){
      print("CARD: $card");

      return new StripeCard.fromSnapshot(card);
    });
  }
}
