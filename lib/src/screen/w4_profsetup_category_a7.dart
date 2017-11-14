import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFRadioGroup.dart';
import 'package:myapp/src/widget/MFButton.dart';

class ProfileSetupCategory extends StatefulWidget {

  @override
  _ProfileSetupCategoryState createState() => new _ProfileSetupCategoryState();
}

class _ProfileSetupCategoryState extends State<ProfileSetupCategory> {

  String categoryVal = "PROFESSIONAL";
  User _user;

  @override
  void initState(){
    super.initState();
    print("INIT CATEGORY.....");
    getCurrentUserProfile().then((usr) {
      if(usr.category == null) {
        categoryVal = "PROFESSIONAL";
      }
      else {
        categoryVal =
            usr.category.toString().replaceAll("DanceCategory.", "").toUpperCase();
      }
      _user = usr;
    });
  }

  void _handleSubmitted() {
    // validate and save
    _user.hasProfileSetup = true;
    saveUser(_user);
    //Navigator.pushReplacementNamed(context, "/mainscreen");
    Navigator.of(context).pushNamedAndRemoveUntil("/mainscreen", (_) => false);
  }

  void _handleCategoryChanged(String val) {
    setState((){
      categoryVal = val;
      _user.category = getDanceCategoryFromString(categoryVal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new MFAppBar("MY PROFILE SETUP", context),
        body: new Container(
          margin: new EdgeInsets.only(right: 30.0, left: 30.0),
          child: new ListView(
            children: <Widget>[
              new Padding(padding: const EdgeInsets.all(20.0)),
              new MFRadio(value: "PROFESSIONAL", labelText: "Professional", groupValue: categoryVal, onChanged: _handleCategoryChanged),
              new Padding(padding: const EdgeInsets.all(10.0)),
              new Container(
                alignment: Alignment.bottomLeft,
                child: new Text(
                  "Professional dancers compete as a Professional Couple, or as a Professional in a Pro-Am Couple.",
                  style: new TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Montserrat-Light",
                  ),
                ),
                height: 60.0,
              ),
              new Padding(padding: const EdgeInsets.all(30.0)),
              new MFRadio(value: "AMATEUR", labelText: "Amateur", groupValue: categoryVal, onChanged: _handleCategoryChanged),
              new Padding(padding: const EdgeInsets.all(10.0)),
              new Container(
                alignment: Alignment.bottomLeft,
                child: new Text(
                  "Amateur dancers compete as an Amateur Couple, or as an Amateur in a Pro-Am Couple.",
                  style: new TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Montserrat-Light",
                  ),
                ),
                height: 60.0,
              ),
              new Padding(padding: const EdgeInsets.all(30.0)),
              new Container(
                child: new MainFrameButton(
                  child: new Text("FINISH PROFILE"),
                  onPressed: _handleSubmitted,
                ),
              )
            ],
          ),
        )
    );
  }
}