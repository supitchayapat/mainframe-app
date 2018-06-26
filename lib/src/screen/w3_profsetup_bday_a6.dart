import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFTextFormField.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/widget/MFRadioGroup.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/util/AnalyticsUtil.dart';

class ProfileSetupBday extends StatefulWidget {

  @override
  _ProfileSetupBdayState createState() => new _ProfileSetupBdayState();
}

class _ProfileSetupBdayState extends State<ProfileSetupBday> {

  TextEditingController _bdayCtrl = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String genderVal = "";
  String headingTitle = "MY PROFILE SETUP";
  User _user;

  void _handleGenderChanged(val) {
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
    if(genderVal.isEmpty) {
      //showInSnackBar('Please fix the errors in red before submitting.');
      showMainFrameDialog(context, "Missing Field", "Please select Gender.");
    } else {
      form.save();
      if(global.dancePartner == null) {
        saveUser(_user);
      } else {

      }
      Navigator.pushNamed(context, "/profilesetup-3");
    }
  }

  @override
  void initState(){
    super.initState();

    global.messageLogs.add("Profile Setup 2 Screen Loaded.");
    AnalyticsUtil.setCurrentScreen("Profile Setup 2", screenClassName: "profile_w3");

    print("INIT BDAY.....");
    if(global.dancePartner == null) {
      getCurrentUserProfile().then((usr) {
        if (usr.birthday != null) {
          _bdayCtrl.text = new DateFormat("MM/dd/yyyy").format(usr.birthday);
        }
        else {
          _bdayCtrl.text = new DateFormat("MM/dd/yyyy").format(new DateTime(1901));
        }
        if (usr.gender == null) {
          genderVal = "MAN";
        } else {
          genderVal =
              usr.gender.toString().replaceAll("Gender.", "").toUpperCase();
        }
        _user = usr;
      });
    } else {
      // setup for dance partner
      setState((){
        headingTitle = "ADD A PARTICIPANT";
        _user = global.dancePartner;
        _bdayCtrl.text = new DateFormat("MM/dd/yyyy").format(new DateTime(1901));
      });
    }
    print("BIRTHDAY: ${_bdayCtrl.text}");
  }

  String _validateBirthday(String val) {
    if(val.isEmpty) {
      return "Birth date Field Required";
    }
    try {
      DateTime dt = new DateFormat("MM/dd/yyyy").parse(val);
    } catch(exception, stackTrace) {
      return "Please enter date in mm/dd/yyyy";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                    alignment: Alignment.bottomLeft,
                    child: new Text(
                      "Birthday",
                      style: new TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Montserrat-Light",
                      ),
                    ),
                    height: 60.0,
                  ),
                  new Padding(padding: const EdgeInsets.all(5.0)),
                  new MFTextFormField(
                    icon: const Icon(Icons.access_time),
                    labelText: ' ',
                    keyboardType: TextInputType.text,
                    onSaved: (String val) {
                      if(val != null && !val.isEmpty) {
                        _user.birthday =
                            new DateFormat("MM/dd/yyyy").parse(val);
                        _bdayCtrl.text = val;
                      }
                    },
                    controller: _bdayCtrl,
                    validator: _validateBirthday,
                    isDatePicker: true,
                  ),
                  new Container(
                    child: new Text(
                      "Gender",
                      style: new TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Montserrat-Light",
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    height: 120.0,
                  ),
                  new Padding(padding: const EdgeInsets.all(5.0)),
                  new MFRadioGroup(
                      radioItems: <MFRadio>[
                        new MFRadio(labelText: "Man", value: "MAN", groupValue: genderVal, onChanged: _handleGenderChanged),
                        new MFRadio(labelText: "Woman", value: "WOMAN", groupValue: genderVal, onChanged: _handleGenderChanged)
                      ]
                  ),

                  new Padding(padding: const EdgeInsets.all(30.0)),
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