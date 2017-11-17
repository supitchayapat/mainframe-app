import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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

Future<dynamic> showAgeCategoryDialog(BuildContext context, List<String> _selectedButtons, VoidCallback onComplete) async {
  List<String> _agesText = <String>[
    "J1 up to 8", "J2 8 to 12",
    "Youth 16 to 18", "Teen 13 to 15",
    "A1 18 to 35", "A2 36 to 50", "B1 51 to 65"
  ];

  List<Widget> _ages = <Widget>[];
  _ages.addAll(_agesText.map((str) {
    return new MaterialButton(
        padding: const EdgeInsets.all(5.0),
        onPressed: (){
          _selectedButtons.add(str);
          Navigator.of(context).pop();
          showAgeCategoryDialog(context, _selectedButtons, onComplete);
        },
        child: new Container(
          decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
              color: _selectedButtons.contains(str) ? new Color(0xff249A9E) : new Color(0xff230E30),
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
    barrierDismissible: false,
    child: new Dialog(
      child: new Container(
        decoration: new BoxDecoration(
            borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
            color: new Color(0xff24041E)
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
                  new Text("SELECT AGE", style: new TextStyle(fontSize: 18.0))
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
                                        color: new Color(0xff230E30)
                                    ),
                                    child: new Column(
                                      children: <Widget>[
                                        new Text("+", style: new TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
                                        new Text("ADD")
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),
                                    alignment: Alignment.center,
                                  )
                              ),
                            ),
                            new Container(
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
                                        color: new Color(0xff230E30)
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
                            )
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