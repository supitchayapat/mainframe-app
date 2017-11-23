import 'package:flutter/material.dart';

class MFAppBar extends AppBar {
  String textTitle;
  VoidCallback backButtonFunc;

  MFAppBar(this.textTitle, BuildContext context, {this.backButtonFunc}) : super(
      title: new Text(
          textTitle,
          style: new TextStyle(
            fontFamily: "Montserrat-Light",
            fontSize: 17.0,
            fontWeight: FontWeight.w100
          ),
      ),
      bottomOpacity: 0.0,
      elevation: 0.0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          color: Colors.white,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if(backButtonFunc != null) {
              backButtonFunc();
            } else {
              Navigator.of(context).maybePop();
            }
          }
      )
  );
}