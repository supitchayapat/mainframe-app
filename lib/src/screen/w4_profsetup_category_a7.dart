import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';

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
    saveUser(_user);
    Navigator.pushNamed(context, "/mainscreen");
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
        appBar: new AppBar(title: new Text("Main Frame Dance Studio")),
        body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Column(
            children: <Widget>[
              new Align(
                alignment: Alignment.centerLeft,
                child: new Text("Dance Category")
              ),
              new Row(
                children: <Widget>[
                  new Radio(value: "PROFESSIONAL", groupValue: categoryVal, onChanged: _handleCategoryChanged),
                  new Text("Professional"),
                  new Radio(value: "AMATEUR", groupValue: categoryVal, onChanged: _handleCategoryChanged),
                  new Text("Amateur")
                ],
              ),
              new Container(
                padding: const EdgeInsets.all(20.0),
                alignment: Alignment.bottomCenter,
                child: new RaisedButton(
                  child: const Text('FINISH'),
                  onPressed: _handleSubmitted,
                ),
              ),
            ],
          ),
        )
    );
  }
}