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

Future<Null> showSummaryDialog(BuildContext context) async {
  double _scrWidth = MediaQuery.of(context).size.width;
  //print(_scrWidth * 0.65);
  //print(340.0 * 0.65);

  return showDialog<Null>(
    context: context,
    barrierDismissible: true, // user must tap button!
    child: new Theme(
        // Dialog Theme
        data: new ThemeData(
          brightness: Brightness.light,
        ),
        // body
        child: new SimpleDialog(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                color: Colors.white,
              ),
              height: 450.0,
              width: 340.0,
              child: new Column(
                children: <Widget>[
                  new Text("Session SUMMARY",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        height: 1.5,
                        fontSize: 16.0,
                        color: const Color(0xff000a12,
                        )
                    ),
                  ),

                  new Container(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: new Divider(color: Colors.black, height: 16.0)
                  ),

                  new Container(
                    //color: Colors.amber,
                    child: new Row(
                      children: <Widget>[
                        new Container(
                          //color: Colors.cyan,
                          width: (MediaQuery.of(context).orientation == Orientation.portrait) ? _scrWidth * 0.6 : 340.0 * 0.8,
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new Container(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Text(
                                      "FRIDAY",
                                      style: new TextStyle(
                                        fontSize: 16.0,
                                        color: const Color(
                                          (0xff000a12),
                                        ),
                                      ),
                                    ),
                                    new Text(
                                      "July 21, 2017",
                                      style: new TextStyle(
                                        fontSize: 12.0,
                                        color: const Color(
                                          (0xff000a12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              new Padding(padding: const EdgeInsets.only(left: 10.0)),
                              new Container(
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Text("ALL DAY",
                                      style: new TextStyle(
                                        fontSize: 16.0,
                                        color: const Color(
                                          (0xff000a12),
                                        ),
                                      ),
                                    ),
                                    new Text(
                                      "with dinner",
                                      style: new TextStyle(
                                        fontSize: 12.0,
                                        color: const Color(
                                          (0xff000a12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              new Padding(padding: const EdgeInsets.only(left: 5.0)),
                              new Container(
                                child: new Row(
                                  children:<Widget>[
                                    new Image.asset("mainframe_assets/images/sun_a60.jpg",
                                      width: 16.0,
                                      height: 16.0,
                                    ),

                                    new Container(
                                      padding: new EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                                      child: new Image.asset("mainframe_assets/images/moon_a60.png",
                                        width: 16.0,
                                        height: 16.0,
                                      ),
                                    ),

                                    new Container(
                                      padding: new EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                                      child: new Image.asset("mainframe_assets/images/food_a60.png",
                                        width: 16.0,
                                        height: 16.0,
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        new Expanded(
                          //padding: const EdgeInsets.all(5.0),
                          child: new Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            decoration: new BoxDecoration(
                                borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                                border: new Border.all(
                                  width: 2.0,
                                  color: const Color(0xFF313746),
                                  style: BorderStyle.solid,
                                ),
                                //color: Colors.green
                            ),
                            height: 40.0,
                            //color: Colors.green,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Text("Total", style: new TextStyle(color: const Color(0xFF778198))),
                                new Text("24", style: new TextStyle(color: const Color(0xFF313746), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  new Container(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: new Divider(color: Colors.black, height: 16.0)
                  ),

                  new Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 10.0),
                    child: new Text("John Doe (21 TICKETS)"),
                  ),
                  
                  new Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      //color: Colors.amber,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: new Text("GENERAL ADMISSION"),
                          ),
                          new Expanded(
                              child: new Container(
                                //color: Colors.cyan,
                                alignment: Alignment.centerRight,
                                child: new Text("11"),
                              )
                          )
                        ],
                      )
                  ),

                  new Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      //color: Colors.amber,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: new Text("STANDING ROOM"),
                          ),
                          new Expanded(
                              child: new Container(
                                //color: Colors.cyan,
                                alignment: Alignment.centerRight,
                                child: new Text("1"),
                              )
                          )
                        ],
                      )
                  ),

                  new Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      //color: Colors.amber,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: new Text("RISERS"),
                          ),
                          new Expanded(
                              child: new Container(
                                //color: Colors.cyan,
                                alignment: Alignment.centerRight,
                                child: new Text("1"),
                              )
                          )
                        ],
                      )
                  ),
                ],
              ),
            )
          ],
        ),
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
