import 'dart:async';
import 'package:flutter/material.dart';

void showInSnackBar(GlobalKey<ScaffoldState> _scaffoldKey, String value) {
  _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value)
  ));
}

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