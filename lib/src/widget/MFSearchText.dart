import 'package:flutter/material.dart';

class MFSearchText extends StatefulWidget {
  TextEditingController controller;
  ValueChanged<String> onChanged;

  MFSearchText({this.controller, this.onChanged});

  @override
  _MFSearchTextState createState() => new _MFSearchTextState();
}

class _MFSearchTextState extends State<MFSearchText> {

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
          primaryColor: new Color(0xFF324261),
          textSelectionColor: Colors.white,
          inputDecorationTheme: new InputDecorationTheme(
            border: InputBorder.none,
          )
      ),
      child: new TextField(
        controller: widget.controller,
        decoration: new InputDecoration(
          //hideDivider: true,
          hintText: "Search Name",
          hintStyle: new TextStyle(
            color: Colors.black,
          ),
        ),
        style: new TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Montserrat-Regular",
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}