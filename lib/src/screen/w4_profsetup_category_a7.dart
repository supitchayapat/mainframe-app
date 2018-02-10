import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFRadioGroup.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/screen/participant_list.dart' as participant;
import 'package:myapp/src/screen/couple_management.dart' as couple;

class ProfileSetupCategory extends StatefulWidget {

  @override
  _ProfileSetupCategoryState createState() => new _ProfileSetupCategoryState();
}

class _ProfileSetupCategoryState extends State<ProfileSetupCategory> {
  String headingTitle = "MY PROFILE SETUP";
  String categoryVal = "PROFESSIONAL";
  User _user;

  @override
  void initState(){
    super.initState();
    print("INIT CATEGORY.....");
    if(global.dancePartner == null) {
      getCurrentUserProfile().then((usr) {
        if (usr.category == null) {
          categoryVal = "PROFESSIONAL";
        }
        else {
          categoryVal =
              usr.category.toString()
                  .replaceAll("DanceCategory.", "")
                  .toUpperCase();
        }
        _user = usr;
        _user.category = getDanceCategoryFromString(categoryVal);
      });
    } else {
      setState((){
        _user = global.dancePartner;
        _user.category = getDanceCategoryFromString(categoryVal);
        headingTitle = "ADD A PARTICIPANT";
      });
    }
    //print(_user.toJson());
  }

  void _handleSubmitted() {
    // validate and save
    _user.hasProfileSetup = true;
    if(global.dancePartner == null) {
      saveUser(_user);
      Navigator.of(context).pushNamedAndRemoveUntil("/mainscreen", (_) => false);
    } else {
      // show loading indicator
      MainFrameLoadingIndicator.showLoading(context);
      global.dancePartner = _user;
      saveUserExistingParticipants(_user).then((_usr){
        print("PARTICIPANT SAVED");
        //check wether add as couple or solo participant
        if(participant.participantType == "solo") {
          // save participant
          saveUserSoloParticipants(_user).then((_val){
            MainFrameLoadingIndicator.hideLoading(context);
            Navigator.of(context).popUntil(ModalRoute.withName("/participants"));
          });
        }
        else if(participant.participantType == "couple") {
          // navigate couple management screen
          MainFrameLoadingIndicator.hideLoading(context);
          if(couple.couple1 is String && couple.couple1 == "_assignCoupleParticipant") {
            setState((){
              couple.couple1 = _user;
            });
          }

          if(couple.couple2 is String && couple.couple2 == "_assignCoupleParticipant") {
            setState((){
              couple.couple2 = _user;
            });
          }
          Navigator.of(context).popUntil(ModalRoute.withName("/coupleManagement"));
        } else {
          Navigator.of(context).popUntil(ModalRoute.withName("/addPartner"));
        }
      });
    }
    //Navigator.pushReplacementNamed(context, "/mainscreen");
  }

  void _handleCategoryChanged(String val) {
    setState((){
      categoryVal = val;
      _user.category = getDanceCategoryFromString(categoryVal);
      print(_user.toJson());
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new MFAppBar(headingTitle, context),
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