import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class MFRadioGroup extends StatefulWidget {
  List<MFRadio> radioItems;

  MFRadioGroup({ @required this.radioItems});

  @override
  _MFRadioGroupState createState() => new _MFRadioGroupState();
}

class _MFRadioGroupState extends State<MFRadioGroup> {

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    children.addAll(widget.radioItems);

    return new Column(
      children: children,
    );
  }
}

class MFRadio<T> extends StatefulWidget {
  final String labelText;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Color activeColor;

  const MFRadio({
    Key key,
    @required this.value,
    @required this.labelText,
    @required this.groupValue,
    @required this.onChanged,
    this.activeColor
  }) : super(key: key);

  @override
  _MFRadioState createState() => new _MFRadioState();
}

class _MFRadioState extends State<MFRadio> {

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Row(
        children: <Widget>[
          new Radio(value: widget.value, groupValue: widget.groupValue, onChanged: widget.onChanged),
          new Padding(padding: const EdgeInsets.only(left: 10.0)),
          new Text(
            widget.labelText,
            style: new TextStyle(
              fontSize: 16.0,
              fontFamily: "Montserrat-Light",
            )
          ),
        ],
      ),
    );
  }
}