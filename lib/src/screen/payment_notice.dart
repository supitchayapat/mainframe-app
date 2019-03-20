import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';

class payment_notice extends StatefulWidget {
  @override
  _payment_noticeState createState() => new _payment_noticeState();
}

class _payment_noticeState extends State<payment_notice> {

  void _handleBackBtn() {
    Navigator.of(context).popUntil(ModalRoute.withName("/event"));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new MFAppBar("PAYMENT PROCESSING", context, backButtonFunc: _handleBackBtn),
      body: new ListView(
        padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
        children: <Widget>[
          new Container(
            alignment: Alignment.center,
            //color: Colors.amber,
            height: 250.0,
            child: new Text(
                "Payment Transaction sent. Thank you",
                style: new TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: "Montserrat-Light", fontWeight: FontWeight.bold)
            ),
          ),
          new Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20.0),
            child: new MainFrameButton(
              child: new Text("Manage Event Entries"),
              onPressed: () {
                Navigator.of(context).popUntil(ModalRoute.withName("/registration"));
              },
            ),
          ),
          new Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20.0),
            child: new MainFrameButton(
              child: new Text("Events"),
              onPressed: () {
                Navigator.of(context).popUntil(ModalRoute.withName("/mainscreen"));
              },
            ),
          ),
        ],
      ),
    );
  }
}