import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFTextFormField.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:validator/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => new _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _email = "";

  void _handleReset() {
    FormState form = _formKey.currentState;
    // crashlytics logging
    global.messageLogs.add("Login button pressed.");
    AnalyticsUtil.sendAnalyticsEvent("login_btn_press", params: {
      'screen': 'email_a2'
    });

    if(!form.validate()) {
      //showInSnackBar(_scaffoldKey, 'Please fix the errors in red before submitting.');
    } else {
      form.save();
      MainFrameLoadingIndicator.showLoading(context);
      FirebaseAuth.instance.sendPasswordResetEmail(email: _email).then((usr) {
        MainFrameLoadingIndicator.hideLoading(context);
        showMainFrameDialog(
            context,
            "Email Sent",
            "A Password reset link has been sent. Please check your email.").then((val){
          Navigator.of(context).pushReplacementNamed("/loginscreen");
        });
      }).catchError((err) {
        MainFrameLoadingIndicator.hideLoading(context);
        showMainFrameDialog(
            context,
            "Reset Error",
            "Sending Reset link to your email failed. Make sure the email you entered is a registered email.");
      });
    }
  }

  String _validateEmail(String value) {
    if(value.isEmpty) {
      return "Email Field Required";
    }
    if(!isEmail(value)){
      return "Invalid Email";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double _height = mediaQuery.size.height;
    double _formHeight = _height - 140.0;
    //double _buttonHeight = _height / 2 - 140.0;
    String imgAsset = "mainframe_assets/images/button_mds.png";
    double fontSize = 18.0, imgHeight = 56.0;

    return new Scaffold(
      appBar: new MFAppBar("FORGOT PASSWORD", context),
      body: new Form(
        key: _formKey,
        child: new ListView(
          children: <Widget>[
            new Container(
              height: _formHeight,
              child: new Column(
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
                      "We will send you a password reset link to your e-mail address.",
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
                      validator: _validateEmail,
                      onSaved: (String val) => _email = val,
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              //margin: EdgeInsets.only(top: _buttonHeight),
              //padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: new MainFrameButton(
                fontSize: 14.0,
                child: new Text("CONTINUE WITH THE APPLICATION"),
                onPressed: _handleReset,
              ),
            )
          ],
        ),
      )
      /*body: new Column(
        children: <Widget>[
          new Container(
            //height: 150.0,
              child: new InkWell(
                onTap: (){},
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    new Container(
                      decoration: new BoxDecoration(
                          image: new DecorationImage(
                              image: new ExactAssetImage(imgAsset),
                              fit: BoxFit.contain
                          )
                      ),
                      height: imgHeight,
                      alignment: Alignment.center,
                      child: new DefaultTextStyle(
                          style: new TextStyle(
                              fontFamily: "Montserrat-Light",
                              fontSize: fontSize,
                              color: Colors.white
                          ),
                          child: new Text("CONTINUE WITH THE APPLICATION")
                      ),
                    )
                  ],
                ),
              )
          ),
        ],
      )*/
    );
  }
}