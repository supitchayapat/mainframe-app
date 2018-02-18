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
    List _expDate = expDate.split("/");
    print("month: ${_expDate[0]} year: ${_expDate[1]}");
    cardNum = cardNum.replaceAll(" ", "-");
    print(cardNum);
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
    return StripePlugin.createToken(cardNum, _expDate[0], _expDate[1], cvv, stripeKey_pk)
        .then((token){
      print("API TOKEN ID: ${token.tokenId}");
      assert(token != null);
      if(isSaveCard) {
        user_ref.child(fuser.uid).child("cardTokens").set({
          "tokenId": token.tokenId,
          "isDefault": isDefault,
          "cardHolder_name": cardHolder,
          "expdate_month": _expDate[0],
          "expdate_year": _expDate[1],
          "brand": token.brand,
          "last4": token.last4,
        });
      }

      Function.apply(p, [token]);
    }).catchError((err) {
      print('CARD ERROR.... $err');
      throw err;
      //showMainFrameDialog(context, "Application Error", "An error occurred during the process. ${err.message}");
    });
  }

  static Future submitPayment(tokenId, amount) async {
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
    PaymentTransaction transaction = new PaymentTransaction(tokenId: tokenId, amount: amount);
    return reference.child(fuser.uid).push().set(transaction.toJson());
  }

  /*static Future createPayment() async {
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
    return StripePlugin.createToken("4242-4242-4242-4242", "12", "2019", "123", "pk_test_I3QbZv331ioLsVDcw4LXxM82")
        .then((token){
      print("API TOKEN ID: $token");
      assert(token != null);
      PaymentTransaction transaction = new PaymentTransaction(tokenId: token.token, amount: 500.0);
      return reference.child(fuser.uid).push().set(transaction.toJson());
    });
  }*/

  static Future<StreamSubscription> stripePaymentListener(Function p) async {
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
    return reference
        .child(fuser.uid)
        .onChildChanged
        .listen((event) {
      if(event.snapshot.value != null && event.snapshot.value.length > 0) {
        print(event.snapshot.value);
        var s = event.snapshot.value;
        StripeCard _card = new StripeCard.fromDataSnapshot(s["charge"]["source"]);
        _card.tokenId = s["tokenId"];
        Function.apply(p, [_card]);
      }
    });
  }

  static Future<dynamic> getExistingCard() async {
    FirebaseUser fuser = await FirebaseAuth.instance.currentUser();
    return user_ref.child(fuser.uid).child("cardTokens").once().then((data){
      print(data?.value);
      return data?.value;
    });
  }
}