
class PaymentTransaction {
  String tokenId;
  int amount;

  PaymentTransaction({this.tokenId, this.amount});

  toJson() {
    return {
      "amount": amount,
      "tokenId": tokenId
    };
  }
}