import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:stripe_plugin/stripe_plugin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/PaymentTransaction.dart';

final reference = FirebaseDatabase.instance.reference().child("stripe_payments");

class PaymentDao {
  static Future createPayment() async {
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
    return StripePlugin.createToken("4242-4242-4242-4242", "12", "2019", "123", "pk_test_I3QbZv331ioLsVDcw4LXxM82")
        .then((token){
      print("API TOKEN ID: $token");
      assert(token != null);
      PaymentTransaction transaction = new PaymentTransaction(tokenId: token, amount: 500.0);
      return reference.child(fuser.uid).push().set(transaction.toJson());
    });
  }
}