import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';

class ProfileSetupName extends StatefulWidget {
  @override
  _ProfileSetupNameState createState() => new _ProfileSetupNameState();
}

class _ProfileSetupNameState extends State<ProfileSetupName> {

  TextEditingController _fnameCtrl = new TextEditingController();
  TextEditingController _lnameCtrl = new TextEditingController();
  TextEditingController _emailCtrl = new TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  User _user;

  @override
  void initState() {
    super.initState();
    print("INIT STATE PROFILE SETUP....");
    getCurrentUserProfile().then((usr) {
      _fnameCtrl.text = usr.first_name;
      _lnameCtrl.text = usr.last_name;
      _emailCtrl.text = usr.email;
      _user = usr;
    });
  }

  @override
  Widget build(BuildContext context) {

    void _handleSubmitted() {
      final FormState form = _formKey.currentState;
      // validate form and save
      form.save();
      // save user using UserDao
      saveUser(_user);
      // navigate to next screen
      Navigator.of(context).pushNamed("/profilesetup-2");
    }

    return new Scaffold(
        appBar: new AppBar(title: new Text("Main Frame Dance Studio")),
        body: new Form(
            key: _formKey,
            child: new Container(
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
                      controller: _fnameCtrl
                  ),
                  new TextFormField(
                      decoration: const InputDecoration(
                          icon: const Icon(Icons.person),
                          hintText: 'Enter Last Name...',
                          labelText: 'Last Name'
                      ),
                      keyboardType: TextInputType.text,
                      onSaved: (String val) => _user.last_name = val,
                      controller: _lnameCtrl
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