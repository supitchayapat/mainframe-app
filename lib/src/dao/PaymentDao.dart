import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:stripe_plugin/stripe_plugin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/model/PaymentTransaction.dart';

final reference = FirebaseDatabase.instance.reference().child("stripe_payments");
final user_ref = FirebaseDatabase.instance.reference().child("users");
final String stripeKey_pk = "pk_test_I3QbZv331ioLsVDcw4LXxM82";
final String stripeKey_sk = "sk_test_U1doXH82rtoluhjZ9ETZ4Hn5";

class PaymentDao {

  static Future createToken(String cardNum, String expDate, String cvv, String cardHolder,
      bool isDefault, bool isSaveCard, Function p) async {
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
    return StripePlugin.createToken("4242-4242-4242-4242", "12", "21", "123", stripeKey_sk)
        .then((token){
      print("API TOKEN ID: $token");
      assert(token != null);
      if(isSaveCard) {
        user_ref.child(fuser.uid).child("cardTokens").push().set({
          "token": token,
          "isDefault": isDefault,
          "cardHolder_name": cardHolder
        });
      }

      Function.apply(p, [token]);
    });
  }

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