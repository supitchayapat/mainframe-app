/*
  Show Dance Solo Free form for World of Dance Celebration 2018
 */
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFTextFormField.dart';

class ShowDanceSolo {
  String dance;

  ShowDanceSolo({this.dance});

  ShowDanceSolo.fromSnapshot(var s){
    dance = s["dance"];
  }

  toJson() {
    return {
      "dance": dance
    };
  }

  Widget toWidget() {


    return new Container(
      //color: Colors.amber,
      child: new Column(
        children: <Widget>[
          //new TextFormField()
          new MFTextFormField(
            //icon: const Icon(Icons.person),
            labelText: 'Dance',
            keyboardType: TextInputType.text,
            onSaved: (String val) => dance = val,
            validator: _validateNotEmpty,
            initialValue: dance != null ? dance : "",
          ),
        ],
      ),
    );
  }

  String _validateNotEmpty(String val) {
    if(val.isEmpty) {
      return "Dance field must not be empty";
    }
    return null;
  }
}