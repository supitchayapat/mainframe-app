import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/util/ScreenUtils.dart';

class ProfileSetupName extends StatefulWidget {
  @override
  _ProfileSetupNameState createState() => new _ProfileSetupNameState();
}

class _ProfileSetupNameState extends State<ProfileSetupName> {

  TextEditingController _fnameCtrl = new TextEditingController();
  TextEditingController _lnameCtrl = new TextEditingController();
  TextEditingController _emailCtrl = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  User _user;

  @override
  void initState() {
    super.initState();
    print("INIT STATE PROFILE SETUP....");
    getCurrentUserProfile().then((usr) {
      if(usr.first_name != null && !usr.first_name.isEmpty) {
        _fnameCtrl.text = usr.first_name;
      }
      if(usr.last_name != null && !usr.last_name.isEmpty) {
        _lnameCtrl.text = usr.last_name;
      }
      if(usr.email != null && !usr.email.isEmpty) {
        _emailCtrl.text = usr.email;
      }
      _user = usr;
    });
  }

  @override
  Widget build(BuildContext context) {

    void _handleSubmitted() {
      final FormState form = _formKey.currentState;
      // validate form and save
      if(!form.validate()) {
        showInSnackBar(_scaffoldKey, 'Please fix the errors in red before submitting.');
      } else {
        form.save();
        // save user using UserDao
        saveUser(_user);
        // navigate to next screen
        Navigator.of(context).pushNamed("/profilesetup-2");
      }
    }

    String _validateNotEmpty(String val) {
      if(val.isEmpty) {
        return "Field must not be empty";
      }
      return null;
    }

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
                        icon: const Icon(Icons.person),
                        hintText: 'Enter First Name...',
                        labelText: 'First Name'
                    ),
                    keyboardType: TextInputType.text,
                    onSaved: (String val) => _user.first_name = val,
                    controller: _fnameCtrl,
                    validator: _validateNotEmpty,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.person),
                        hintText: 'Enter Last Name...',
                        labelText: 'Last Name'
                    ),
                    keyboardType: TextInputType.text,
                    onSaved: (String val) => _user.last_name = val,
                    controller: _lnameCtrl,
                    validator: _validateNotEmpty,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.email),
                        hintText: 'Enter Email...',
                        labelText: 'Email'
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String val) => _user.email = val,
                    controller: _emailCtrl
                  ),
                  new Container(
                    padding: const EdgeInsets.all(20.0),
                    alignment: Alignment.bottomCenter,
                    child: new RaisedButton(
                      child: const Text('NEXT'),
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