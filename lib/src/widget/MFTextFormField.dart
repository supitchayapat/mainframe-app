import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MFTextFormField extends StatefulWidget {
  String labelText;
  String hintText;
  Icon icon;
  FormFieldSetter<String> onSaved;
  FormFieldValidator<String> validator;
  bool obscureText;
  TextInputType keyboardType;
  TextEditingController controller;
  String initialValue;
  bool isEnabled;

  MFTextFormField({
    this.labelText,
    this.hintText,
    this.icon,
    this.onSaved,
    this.validator,
    this.obscureText : false,
    this.keyboardType : TextInputType.text,
    this.controller,
    this.initialValue : "",
    this.isEnabled : true
  });

  @override
  _MFTextFormFieldState createState() => new _MFTextFormFieldState();
}

class _MFTextFormFieldState extends State<MFTextFormField> {

  @override
  Widget build(BuildContext context) {
    List<Widget> rowItems = <Widget>[];
    Alignment align = Alignment.topLeft;
    EdgeInsets padding = new EdgeInsets.only(bottom: 0.0);
    InputDecoration decoration = new InputDecoration(
        //icon: widget.icon,
        hintText: widget.hintText,
        labelText: widget.labelText,
        hideDivider: true,
    );

    Widget field = new TextFormField(
      decoration: decoration,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      onSaved: widget.onSaved,
      validator: widget.validator,
      controller: widget.controller,
      initialValue: widget.initialValue,
    );

    TextStyle style = new TextStyle(
      fontFamily: "Montserrat-Regular",
      fontSize: 16.0
    );

    if(!widget.isEnabled) {
      if(widget.initialValue != null) {
        field = new Text(widget.controller.text, style: style);
      }
      else {
        field = new Text(widget.labelText, style: style);
      }
      align = Alignment.bottomLeft;
      padding = new EdgeInsets.only(bottom: 10.0);
    }

    if(widget.icon != null) {
      rowItems.add(
        new Container(
          //color: Colors.amber,
          child: widget.icon,
          margin: const EdgeInsets.only(top: 20.0),
        )
      );
      rowItems.add(new Padding(padding: const EdgeInsets.only(left: 10.0)));
    }
    rowItems.add(
      new Expanded(
          child: new Container(
            padding: padding,
            alignment: align,
            //color: Colors.indigo,
            child: field,
            //height: 50.0,
            constraints: new BoxConstraints(
              minHeight: 55.0
            ),
          )
      )
    );

    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new Row(
              children: rowItems,
            ),
            decoration: new BoxDecoration(
              border: new Border(
                bottom: new BorderSide(
                  color: Colors.white
                )
              )
            ),
          ),
        ],
      ),
    );
  }
}