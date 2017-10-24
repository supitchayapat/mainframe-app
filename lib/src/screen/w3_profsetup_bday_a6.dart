import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/Gender.dart';

class ProfileSetupBday extends StatefulWidget {

  @override
  _ProfileSetupBdayState createState() => new _ProfileSetupBdayState();
}

class _ProfileSetupBdayState extends State<ProfileSetupBday> {

  TextEditingController _bdayCtrl = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String genderVal = "MALE";
  User _user;

  void _handleGenderChanged(String val) {
    setState((){
      genderVal = val;
      _user.gender = getGenderFromString(genderVal);
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value)
    ));
  }

  void _handleSubmitted() {
    // perform validation and save
    final FormState form = _formKey.currentState;
    if(!form.validate()) {
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      saveUser(_user);
      Navigator.pushNamed(context, "/profilesetup-3");
    }
  }

  @override
  void initState(){
    super.initState();
    print("INIT BDAY.....");
    getCurrentUserProfile().then((usr) {
      _bdayCtrl.text = new DateFormat("MM/dd/yyyy").format(usr.birthday);
      if(usr.gender == null) {
        genderVal = "MALE";
      } else {
        genderVal =
            usr.gender.toString().replaceAll("Gender.", "").toUpperCase();
      }
      _user = usr;
    });
  }

  String _validateBirthday(String val) {
    if(val.isEmpty) {
      return "Birth date Field Required";
    }
    try {
      DateTime dt = new DateFormat("MM/dd/yyyy").parse(val);
    } catch(exception, stackTrace) {
      return "invalid format. Please enter date in mm/dd/yyyy";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(title: new Text("Main Frame Dance Studio")),
        body: new Form(
            key: _formKey,
            child: new Container(
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.access_time),
                        hintText: 'Enter Date of Birth...',
                        labelText: 'Birth date'
                    ),
                    keyboardType: TextInputType.text,
                    onSaved: (String val) => _user.birthday = new DateFormat("MM/dd/yyyy").parse(val),
                    controller: _bdayCtrl,
                    validator: _validateBirthday,
                  ),
                  new Row(
                    children: <Widget>[
                      new Radio(value: "MALE", groupValue: genderVal, onChanged: _handleGenderChanged),
                      new Text("Male"),
                      new Radio(value: "FEMALE", groupValue: genderVal, onChanged: _handleGenderChanged),
                      new Text("Female")
                    ],
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