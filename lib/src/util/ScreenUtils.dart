import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:facebook_sign_in/facebook_sign_in.dart';

/*
  Author: Art

  The dart file contains Screen utility methods

  ShowInSnackBar is a method that shows snackbar
  that accepts a string value to show
 */
void showInSnackBar(GlobalKey<ScaffoldState> _scaffoldKey, String value) {
  _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value)
  ));
}

/*
  Facebook Share Dialog
 */
void showFacebookAppShareDialog() {
  FacebookSignIn.shareDialog();
}

/*
  A method that shows a dialog screen
  that accepts a String message and a string title
 */
Future<Null> showMainFrameDialog(BuildContext context, String title, String msg) async {

  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    child: new AlertDialog(
      title: new Text(title),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(msg)
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

/*
  A method that shows a dialog screen with cancel option.
  It accepts a String message and a string title
 */
Future<Null> showMainFrameDialogWithCancel(BuildContext context, String title, String msg) async {

  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    child: new AlertDialog(
      title: new Text(title),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(msg)
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('CANCEL'),
          onPressed: () {
            Navigator.pop(context, "CANCEL");
          },
        ),
        new FlatButton(
          child: new Text('OK'),
          onPressed: () {
            Navigator.pop(context, "OK");
          },
        ),
      ],
    ),
  ).then((val){
    return val;
  });
}

/*
  A method that shows a dialog screen
  the dialog contains a selection of Age categories
 */
Future<dynamic> showAgeCategoryDialog(BuildContext context, List<String> _selectedButtons, VoidCallback onComplete, {List<int> ages}) async {
  List<String> _agesText = <String>[
    "J1 up to 8", "J2 8 to 12",
    "Youth 16 to 18", "Teen 13 to 15",
    "A1 18 to 35", "A2 36 to 50", "B1 51 to 65"
  ];
  List<String> _enabledAges = [];

  if(ages != null && ages.length > 0) {
    ages.forEach((f){
      if(f <= 8) {
        // J1 up to 8
        _enabledAges.add("J1 up to 8");
      } else if(f <= 12 && f >= 8) {
        // J2 8 to 12
        _enabledAges.add("J2 8 to 12");
      } else if(f <= 18 && f >= 16) {
        // Youth 16 to 18
        _enabledAges.add("Youth 16 to 18");
      } else if(f <= 15 && f >= 13) {
        // Teen 13 to 15
        _enabledAges.add("Teen 13 to 15");
      } else if(f <= 35 && f >= 18) {
        // A1 18 to 35
        _enabledAges.add("A1 18 to 35");
      } else if(f <= 50 && f >= 36) {
        // A2 36 to 50
        _enabledAges.add("A2 36 to 50");
      } else if(f <= 65 && f >= 51) {
        // B1 51 to 65
        _enabledAges.add("B1 51 to 65");
      }
    });
  } else {
    _enabledAges = _agesText;
  }

  List<Widget> _ages = <Widget>[];
  _ages.addAll(_agesText.map((str) {
    return new MaterialButton(
        padding: const EdgeInsets.all(5.0),
        onPressed: (){
          if(_enabledAges.contains(str)) {
            if (_selectedButtons.contains(str)) {
              _selectedButtons.remove(str);
            } else {
              _selectedButtons.add(str);
            }
            Navigator.of(context).pop();
            showAgeCategoryDialog(context, _selectedButtons, onComplete, ages: ages);
          }
        },
        child: new Container(
          decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
              color: _selectedButtons.contains(str) ? new Color(0xff249A9E) : (_enabledAges.contains(str) ? new Color(0xff335577) : new Color(0xff556c8f)),
              //color: _filteredColor(str, _selectedButtons, _enabledAges)
              /*image: new DecorationImage(
                  image: new ExactAssetImage("mainframe_assets/images/age_modal_btn.png"),
                  fit: BoxFit.cover,
              )*/
          ),
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 50.0, right: 50.0),
          child: new Text(str),
          alignment: Alignment.centerLeft,
        )
    );
  }).toList());

  double heightOverflow = 345.0;
  if(MediaQuery.of(context).orientation == Orientation.landscape) {
    heightOverflow = 260.0;
  }

  return showDialog<Null>(
    context: context,
    //barrierDismissible: false,
    child: new Dialog(
      child: new Container(
        decoration: new BoxDecoration(
            borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
            color: new Color(0xff364864),
            boxShadow: <BoxShadow>[
              new BoxShadow(
                blurRadius: 1.0,
                spreadRadius: 1.0
              )
            ]
        ),
        height: 390.0,
        width: 180.0,
        child: new Column(
          children: <Widget>[
            new Container(
              //color: Colors.amber,
              height: 45.0,
              child: new Row(
                children: <Widget>[
                  new Container(
                      width: 80.0,
                      child: new IconButton(
                          icon: new Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            _selectedButtons = <String>[];
                            Navigator.of(context).pop();
                          }
                      )
                  ),
                  new Text("SELECT AGE[S]", style: new TextStyle(fontSize: 18.0))
                ],
              ),
            ),
            new Container(
              height: heightOverflow,
              child: new ListView(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Container(
                        width: 215.0,
                        child: new Column(
                          children: _ages,
                        ),
                      ),
                      new Expanded(
                        //color: Colors.amber,
                        child: new Column(
                          children: <Widget>[
                            new Container(
                              child: new MaterialButton(
                                  padding: const EdgeInsets.all(5.0),
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                    onComplete();
                                  },
                                  child: new Container(
                                    height: 80.0,
                                    decoration: new BoxDecoration(
                                        borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                                        color: new Color(0xff335577)
                                    ),
                                    /*child: new Column(
                                      children: <Widget>[
                                        //new Text("+", style: new TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
                                        new Icon(Icons.check),
                                        new Text("OK")
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),*/
                                    child: new Text("OK", style: new TextStyle(fontWeight: FontWeight.bold)),
                                    alignment: Alignment.center,
                                  )
                              ),
                            ),
                            /*new Container(
                              child: new MaterialButton(
                                  padding: const EdgeInsets.all(5.0),
                                  onPressed: () {
                                    _selectedButtons = <String>[];
                                    Navigator.of(context).pop();
                                  },
                                  child: new Container(
                                    height: 80.0,
                                    decoration: new BoxDecoration(
                                        borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                                        color: new Color(0xff335577)
                                    ),
                                    child: new Column(
                                      children: <Widget>[
                                        new Text("x", style: new TextStyle(fontSize: 30.0)),
                                        new Text("CANCEL", style: new TextStyle(fontSize: 12.0))
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),
                                    alignment: Alignment.center,
                                  )
                              ),
                            )*/
                          ],
                        )
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  )
                ],
              ),
            )
          ],
        )
      ),
    )
  );
}
