import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFTextFormField.dart';
import 'package:myapp/src/widget/MFButton.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => new _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new MFAppBar("FORGOT PASSWORD", context),
      body: new ListView(
        children: <Widget>[
          new Container(
            child: new Text("Forgot your password?", style: new TextStyle(fontSize: 24.0)),
            height: 140.0,
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 20.0),
          ),
          new Container(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: new Text(
                "We will send you a six digit code to confirm your e-mail address.",
                style: new TextStyle(
                  fontSize: 16.0,
                  fontFamily: "Montserrat-Light",
                ),
            ),
          ),
          new Container(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: new MFTextFormField(
              labelText: 'Email',
              icon: new Icon(Icons.email, color: Colors.white),
              //validator: _validateEmail,
              //onSaved: (String val) => _user.email = val,
            ),
          ),
          new Padding(padding: const EdgeInsets.all(80.0)),
          new Container(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: new MainFrameButton(
              fontSize: 14.0,
              child: new Text("CONTINUE WITH THE APPLICATION"),
              //onPressed: _handleLogin,
            ),
          )
        ],
      ),
      /*bottomNavigationBar: new Container(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
        height: 120.0,
        child: new MainFrameButton(
          fontSize: 14.0,
          child: new Text("CONTINUE WITH THE APPLICATION"),
          //onPressed: _handleLogin,
        ),
      ),*/
    );
  }
}