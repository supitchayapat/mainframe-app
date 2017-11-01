import 'dart:async';
import 'package:flutter/material.dart';

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