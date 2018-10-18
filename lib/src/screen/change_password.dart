import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFTextFormField.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/util/HttpUtil.dart';
import 'forgotpass_success.dart' as fp;
import 'package:myapp/src/util/ScreenUtils.dart';

class change_password extends StatefulWidget {
  @override
  _change_passwordState createState() => new _change_passwordState();
}

var changepassToken;

class _change_passwordState extends State<change_password> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _newCtrl = new TextEditingController();
  TextEditingController _confirmCtrl = new TextEditingController();
  String newPassword;
  String confirmPassword;
  String tokenId;

  void _handleChangePass() {
    FormState form = _formKey.currentState;
    // crashlytics logging
    global.messageLogs.add("Change password submitted.");
    AnalyticsUtil.sendAnalyticsEvent("changepass_btn_press", params: {
      'screen': 'change_password'
    });

    if(!form.validate()) {
      //showInSnackBar(_scaffoldKey, 'Please fix the errors in red before submitting.');
    } else {
      form.save();
      MainFrameLoadingIndicator.showLoading(context);
      HttpUtil.requestChangePassword(context, tokenId, newPassword).then((resp) {
        print("request responded");
        if(resp != null) {
          var jsonRes = json.decode(resp.body);
          var message = jsonRes["message"];
          var code = jsonRes["code"];

          switch (code) {
            case 100:
              fp.fpMessage = message;
              break;
            case 500:
              fp.fpMessage =
              "Error: An internal Server error occurred during the process. Please contact Support.";
              break;
            case 305:
              fp.fpMessage =
              "The Change Pasword Request already Expired. Please go to login screen and tap Forgot Password.";
              break;
            case 304:
              fp.fpMessage =
              "Could not find Change Password Request. Please go to login screen and tap Forgot Password.";
              break;
            default:
              fp.fpMessage = null;
          }
        }
        else {
          fp.fpMessage = null;
        }
        MainFrameLoadingIndicator.hideLoading(context);
        Navigator.of(context).pushReplacementNamed("/forgotpass-success");
      }).catchError((err) {
        MainFrameLoadingIndicator.hideLoading(context);
        showMainFrameDialog(context, "Error", err.message);
      });
    }
  }

  String _validatePassword(value) {
    if(value.isEmpty) {
      return "Field Required";
    }
    return null;
  }

  String _confirmPassword(value) {
    if(value.isEmpty) {
      return "Field Required";
    }
    print("$value == ${_newCtrl.text}");
    if(value != _newCtrl.text) {
      return "Password did not match";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    //email = "zikoje@1shivom.com";
    //oldPassword = "testing";
    if(changepassToken != null) {
      tokenId = changepassToken;
    }
    //showMainFrameDialog(context, "tokenId", tokenId);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double _height = mediaQuery.size.height;
    double _formHeight = _height - 140.0;

    return new Scaffold(
        appBar: new MFAppBar("CHANGE PASSWORD", context),
        body: new Form(
          key: _formKey,
          child: new ListView(
            children: <Widget>[
              new Container(
                height: _formHeight,
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Text("Change password", style: new TextStyle(fontSize: 24.0)),
                      height: 140.0,
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 20.0),
                    ),
                    new Container(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: new Text(
                        "Please input new Password.",
                        style: new TextStyle(
                          fontSize: 16.0,
                          fontFamily: "Montserrat-Light",
                        ),
                      ),
                    ),
                    new Container(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: new MFTextFormField(
                        labelText: 'New Password',
                        controller: _newCtrl,
                        icon: new Icon(Icons.lock, color: Colors.white),
                        validator: _validatePassword,
                        onSaved: (String val) => newPassword = val,
                        obscureText: true,
                      ),
                    ),
                    new Container(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: new MFTextFormField(
                        labelText: 'Confirm Password',
                        controller: _confirmCtrl,
                        icon: new Icon(Icons.lock, color: Colors.white),
                        validator: _confirmPassword,
                        onSaved: (String val) => confirmPassword = val,
                        obscureText: true,
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
                  child: new Text("CHANGE PASSWORD"),
                  onPressed: _handleChangePass,
                ),
              )
            ],
          ),
        )
    );
  }
}