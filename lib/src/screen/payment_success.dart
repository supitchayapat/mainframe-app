import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/MFGlobals.dart' as global;

class payment_success extends StatefulWidget {
  @override
  _payment_successState createState() => new _payment_successState();
}

class _payment_successState extends State<payment_success> {

  @override
  void initState(){
    super.initState();
    // logging for crashlytics
    global.messageLogs.add("Payment Success Screen loaded.");
    AnalyticsUtil.setCurrentScreen("GPayment Success", screenClassName: "payment_success");
  }

  void _handleBackBtn() {
    Navigator.of(context).popUntil(ModalRoute.withName("/event"));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new MFAppBar("PAYMENT SUCCESS", context, backButtonFunc: _handleBackBtn),
      body: new ListView(
        padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
        children: <Widget>[
          new Container(
            alignment: Alignment.center,
            //color: Colors.amber,
            height: 250.0,
            child: new Text(
                "Thanks for Purchasing!",
                style: new TextStyle(fontSize: 22.0, color: Colors.white, fontFamily: "Montserrat-Light", fontWeight: FontWeight.bold)
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