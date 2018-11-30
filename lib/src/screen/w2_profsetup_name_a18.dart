import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/widget/MFTextFormField.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:validator/validator.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/src/dao/DeviceInfoDao.dart';
import 'package:myapp/MFGlobals.dart' as global;

var pGender;
var pBirthDay;
var pCategory;

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
  bool isEmailEnabled = false;
  String headingTitle = "MY PROFILE SETUP";
  String textDescription = "Please provide the following information so we can accurately provide features that are specific to you.";

  User _user;

  @override
  void initState() {
    super.initState();
    pGender = null;
    pBirthDay = null;
    pCategory = null;

    global.messageLogs.add("Profile Setup 1 Screen Loaded.");
    AnalyticsUtil.setCurrentScreen("Profile Setup 1", screenClassName: "GroupDance");
    DeviceInfoDao.updateStatus("Profile Setup Name Screen");

    print("INIT STATE PROFILE SETUP....");
    if(global.dancePartner == null) {
      getCurrentUserProfile().then((usr) {
        setState(() {
          if (usr.first_name != null && !usr.first_name.isEmpty) {
            _fnameCtrl.text = usr.first_name;
          }
          if (usr.last_name != null && !usr.last_name.isEmpty) {
            _lnameCtrl.text = usr.last_name;
          }
          if (usr.email != null && !usr.email.isEmpty) {
            _emailCtrl.text = usr.email;
          }
          _user = usr;
        });
      });
    } else {
      // setup for dance partner
      print(global.dancePartner.toJson());
      getCurrentUserProfile().then((usr) {
        setState(() {
          _fnameCtrl.text = global.dancePartner.first_name;
          _lnameCtrl.text = global.dancePartner.last_name;
          _emailCtrl.text = global.dancePartner.email;
          if(global.dancePartner.email == null || global.dancePartner.email.isEmpty) {
            isEmailEnabled = true;
          }
          headingTitle = "ADD A PARTICIPANT";
          textDescription = "Please provide the following information accurately.";
          _user = new User(first_name: _fnameCtrl.text, last_name: _lnameCtrl.text, email: _emailCtrl.text);
        });
      });
    }
  }

  void _handleSubmitted() {
    DeviceInfoDao.updateStatus("Clicked Next Button");
    final FormState form = _formKey.currentState;
    // validate form and save
    if(!form.validate()) {
      showInSnackBar(_scaffoldKey, 'Please fix the errors in red before submitting.');
    } else {
      form.save();
      if(global.dancePartner == null) {
        // save user using UserDao
        saveUser(_user);
      } else {
        global.dancePartner = _user;
      }
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

  String _validateEmail(String value) {
    if(!value.isEmpty && !isEmail(value)){
      return "Invalid Email";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double _height = mediaQuery.size.height;
    double _formHeight = _height - 140.0;

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new MFAppBar(headingTitle, context),
        body: new Form(
            key: _formKey,
            child: new Container(
              margin: new EdgeInsets.only(right: 30.0, left: 30.0),
              child: new ListView(
                children: <Widget>[
                  new Container(
                    height: _formHeight,
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          child: new Text(
                            textDescription,
                            style: new TextStyle(
                              fontSize: 16.0,
                              fontFamily: "Montserrat-Light",
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                          height: 120.0,
                        ),
                        new Padding(padding: const EdgeInsets.all(10.0)),
                        new MFTextFormField(
                            icon: const Icon(Icons.person),
                            labelText: 'First Name',
                            keyboardType: TextInputType.text,
                            onSaved: (String val) => _user.first_name = val,
                            controller: _fnameCtrl,
                            validator: _validateNotEmpty
                        ),
                        new MFTextFormField(
                          icon: const Icon(Icons.person),
                          labelText: 'Last Name',
                          keyboardType: TextInputType.text,
                          onSaved: (String val) => _user.last_name = val,
                          controller: _lnameCtrl,
                          validator: _validateNotEmpty,
                        ),
                        new MFTextFormField(
                          icon: const Icon(Icons.email),
                          labelText: 'Email',
                          keyboardType: TextInputType.text,
                          onSaved: (String val) => _user.email = val,
                          controller: _emailCtrl,
                          validator: isEmailEnabled ? _validateEmail : _validateNotEmpty,
                          //initialValue: _user.email != null ? _user.email : "",
                          isEnabled: isEmailEnabled,
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    child: new MainFrameButton(
                      child: new Text("CONTINUE"),
                      onPressed: _handleSubmitted,
                    ),
                  )
                ],
              ),
            )
        )
    );
  }
}