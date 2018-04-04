import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:validator/validator.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/demo/demo.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/widget/MFTextFormField.dart';

class EmailLogin extends StatefulWidget {
  @override
  _EmailLoginState createState() => new _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _signUpFormKey = new GlobalKey<FormState>();
  String pwd = "";
  User _user;

  @override
  void initState() {
    super.initState();
    _user = new User();
  }

  void _handleSignUp() {
    print("SIGN UP HANDLED");
    FormState form = _signUpFormKey.currentState;
    if(!form.validate()) {
      //showInSnackBar(_scaffoldKey, 'Please fix the errors in red before submitting.');
    } else {
      form.save();
      MainFrameLoadingIndicator.showLoading(context);
      registerEmail(_user.email, pwd).then((usr) {
        MainFrameLoadingIndicator.hideLoading(context);
        Navigator.of(context).pushReplacementNamed("/profilesetup-1");
      }).catchError((err) {
        MainFrameLoadingIndicator.hideLoading(context);
        print("ErrorType: ${err.runtimeType}");
        print("Error Msg: ${err.message}");
        if(err.message == "FIRAuthErrorDomain") {
          showMainFrameDialog(context, "Sign Up Error", "Account already exist, make sure you are not using the same email with a facebook account.");
        } else {
          showMainFrameDialog(context, "Sign Up Error", err.message);
        }
      });
    }
  }

  void _handleLogin() {
    FormState form = _formKey.currentState;
    print("LOGIN HANDLED");
    if(!form.validate()) {
      //showInSnackBar(_scaffoldKey, 'Please fix the errors in red before submitting.');
    } else {
      form.save();
      MainFrameLoadingIndicator.showLoading(context);
      loginWithEmail(_user.email, pwd).then((usr) {
        MainFrameLoadingIndicator.hideLoading(context);
        Navigator.of(context).pushReplacementNamed("/mainscreen");
      }).catchError((err) {
        MainFrameLoadingIndicator.hideLoading(context);
        showMainFrameDialog(context, "Login Error", "The password is invalid, or the user email does not exist.");
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

  String _validPassword(String value) {
    if(value.isEmpty) {
      return "Password Field Required";
    }
    if(value.length < 6) {
      return "Password must be atleast 6 characters";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    Widget _buildLogin() {
      return new Form(
          key: _formKey,
          child: new Container(
            padding: new EdgeInsets.all(20.0),
            child: new ListView(
              children: <Widget>[
                new MFTextFormField(
                  labelText: 'Email',
                  icon: new Icon(Icons.email, color: Colors.white),
                  validator: _validateEmail,
                  onSaved: (String val) => _user.email = val,
                ),
                new MFTextFormField(
                  labelText: 'Password',
                  icon: new Icon(Icons.lock, color: Colors.white),
                  validator: _validPassword,
                  onSaved: (String val) => pwd = val,
                  obscureText: true,
                ),
                new Padding(padding: const EdgeInsets.all(30.0)),
                new Container(
                  alignment: Alignment.bottomCenter,
                  child: new MainFrameButton(
                    child: new Text("LOG IN"),
                    onPressed: _handleLogin,
                  ),
                ),
                new Padding(padding: const EdgeInsets.all(15.0)),
                new Center(
                  child: new MaterialButton(
                      onPressed: () => Navigator.of(context).pushNamed("/forgot-password"),
                      child: new Text("Forgot Password?", style: new TextStyle(color: Colors.grey, fontSize: 16.0)),
                  )
                )
              ],
            ),
          )
      );
    }

    Widget _buildSignUp() {
      return new Form(
          key: _signUpFormKey,
          child: new Container(
            padding: new EdgeInsets.all(20.0),
            child: new ListView(
              children: <Widget>[
                new MFTextFormField(
                  labelText: 'Email',
                  icon: new Icon(Icons.email, color: Colors.white),
                  validator: _validateEmail,
                  onSaved: (String val) => _user.email = val,
                ),
                new MFTextFormField(
                  labelText: 'Password',
                  icon: new Icon(Icons.lock, color: Colors.white),
                  validator: _validPassword,
                  onSaved: (String val) => pwd = val,
                  obscureText: true,
                ),
                new Padding(padding: const EdgeInsets.all(30.0)),
                new Container(
                  alignment: Alignment.bottomCenter,
                  child: new MainFrameButton(
                    child: new Text("SIGN UP"),
                    onPressed: _handleSignUp,
                  ),
                )
              ],
            ),
          )
      );
    }

    return new TabbedComponentDemoScaffold(
        hasBackButton: true,
        title: " ",
        demos: <ComponentDemoTabData>[
          new ComponentDemoTabData(
              tabName: 'LOG IN',
              description: '',
              demoWidget: _buildLogin()
          ),
          new ComponentDemoTabData(
              tabName: 'SIGN UP',
              description: '',
              demoWidget: _buildSignUp()
          )
        ]
    );
  }
}