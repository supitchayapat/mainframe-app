import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/model/User.dart';
import 'package:validator/validator.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/util/FirebaseCrashReport.dart';

class EmailLogin extends StatefulWidget {
  @override
  _EmailLoginState createState() => new _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String pwd = "";
  User _user;

  @override
  void initState() {
    super.initState();
    _user = new User(null, null, null, null, null, null, null, null);
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if(!form.validate()) {
      showInSnackBar(_scaffoldKey, 'Please fix the errors in red before submitting.');
    } else {
      form.save();
      MainFrameLoadingIndicator.showLoading(context);
      loginWithEmail(_user.email, pwd).then((usr) {
            MainFrameLoadingIndicator.hideLoading(context);
            Navigator.of(context).pushReplacementNamed("/mainscreen");
          }).catchError((err) {
              MainFrameLoadingIndicator.hideLoading(context);
              MainFrameCrashReport.send(err.message);
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
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: new Text("Main Frame Dance Studio"), automaticallyImplyLeading: false),
        body: new Form(
            key: _formKey,
            child: new Container(
              padding: new EdgeInsets.all(20.0),
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.email),
                        hintText: 'Enter Email...',
                        labelText: 'Email'
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String val) => _user.email = val,
                    validator: _validateEmail,
                  ),
                  new TextFormField(
                      decoration: const InputDecoration(
                          icon: const Icon(Icons.lock),
                          hintText: 'Enter Password...',
                          labelText: 'Password'
                      ),
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      onSaved: (String val) => pwd = val,
                      validator: _validPassword,
                  ),
                  new Container(
                    padding: const EdgeInsets.all(20.0),
                    alignment: Alignment.bottomCenter,
                    child: new RaisedButton(
                      child: const Text('LOGIN'),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                ],
              ),
            )
        )
    );
  }
}