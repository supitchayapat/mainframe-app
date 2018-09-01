import 'package:flutter/material.dart';

class MFSearchText extends StatefulWidget {
  TextEditingController controller;
  ValueChanged<String> onChanged;
  var dataItems;

  MFSearchText({this.controller, this.onChanged, this.dataItems});

  @override
  _MFSearchTextState createState() => new _MFSearchTextState();
}

class _MFSearchTextState extends State<MFSearchText> {
  var initialDataItems;

  void _searchChange(String val) {
    Map<String, dynamic> _filtered = {};
    setState(() {
      if(initialDataItems == null && widget.dataItems != null) {
        initialDataItems = widget.dataItems;
      }
      print(initialDataItems.runtimeType);
      if(val.isEmpty) {
        widget.dataItems = initialDataItems;
      }
      else {
        initialDataItems.forEach((String key, item){
          if(key.toLowerCase().contains(val.toLowerCase())) {
            _filtered.putIfAbsent(key, () => item);
          }
          widget.dataItems = _filtered;
          print("length = ${widget.dataItems.length}");
        });
      }
    });
  }

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
        onChanged: widget.onChanged != null ? widget.onChanged : _searchChange,
      ),
    );
  }
}