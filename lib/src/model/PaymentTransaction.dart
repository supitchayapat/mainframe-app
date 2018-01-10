
class PaymentTransaction {
  String tokenId;
  double amount;

  PaymentTransaction({this.tokenId, this.amount});

  toJson() {
    return {
      "amount": amount,
      "tokenId": tokenId
    };
  }
}