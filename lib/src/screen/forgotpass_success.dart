import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';

var fpMessage;

class forgotpass_success extends StatefulWidget {
  @override
  _forgotpass_successState createState() => new _forgotpass_successState();
}

class _forgotpass_successState extends State<forgotpass_success> {
  String responseMsg = "Success";

  @override
  void initState() {
    super.initState();
    if(fpMessage != null) {
      setState(() {
        responseMsg = fpMessage;
      });
    }
  }

  void _handleBackBtn() {
    Navigator.of(context).popUntil(ModalRoute.withName("/emailLogin"));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new MFAppBar("FORGOT PASSWORD", context),
      body: new Container(
        padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new Container(
                margin: const EdgeInsets.only(top: 120.0),
                child: new Text(
                    responseMsg,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      fontSize: 22.0,
                      color: Colors.white,
                      fontFamily: "Montserrat-Light",
                      fontWeight: FontWeight.bold,
                    )
                ),
              )
            ),
            new Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20.0),
              child: new MainFrameButton(
                child: new Text("LOGIN"),
                onPressed: () {
                  Navigator.of(context).pushNamed("/emailLogin");
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}