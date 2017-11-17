import 'package:flutter/material.dart';

class MainFrameButton extends FlatButton {
  String imgAsset;
  double fontSize;
  double imgHeight;
  MainFrameButton({this.imgAsset : "mainframe_assets/images/button_mds.png",this.fontSize : 18.0, this.imgHeight: 56.0, Key key, Brightness colorBrightness, ButtonTextTheme textTheme,
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
                    image: new ExactAssetImage(imgAsset),
                    fit: BoxFit.contain
                )
            ),
            height: imgHeight,
            alignment: Alignment.center,
            child: new DefaultTextStyle(
                style: new TextStyle(
                  fontFamily: "Montserrat-Light",
                  fontSize: fontSize,
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