import 'package:flutter/material.dart';

class MainFrameButton extends FlatButton {
  MainFrameButton({Key key, Brightness colorBrightness, ButtonTextTheme textTheme,
      Color textColor, Color color, Color splashColor, Color highlightColor, double elevation,
      double highlightElevation, double minWidth, double height, EdgeInsetsGeometry padding,
      VoidCallback onPressed, Widget child}) :
        super(key: key, colorBrightness: colorBrightness, textTheme: textTheme,
      textColor: textColor, color: color, splashColor: splashColor,
          highlightColor: highlightColor, onPressed: onPressed, child: child);

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new ExactAssetImage("mainframe_assets/images/button_mds.png"),
                    fit: BoxFit.contain
                )
            ),
            height: 56.0,
            alignment: Alignment.center,
            child: new DefaultTextStyle(
                style: new TextStyle(
                  fontFamily: "Montserrat-Light",
                  fontSize: 18.0,
                  color: Colors.white
                ),
                child: child
            ),
          )
        ],
      ),
    );
  }
}