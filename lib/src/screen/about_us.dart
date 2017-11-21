import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => new _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new MFAppBar("CONTACT US", context),
      body: new Column(
        children: <Widget>[
          new Container(
            alignment: Alignment.center,
            //color: Colors.amber,
            height: 250.0,
            child: new Text(
                "Logo Placeholder",
                style: new TextStyle(fontSize: 15.0, color: Colors.white, fontFamily: "Montserrat-Light")
            ),
          ),
          new Container(
              padding: const EdgeInsets.all(20.0),
              height: 120.0,
              alignment: Alignment.center,
              child: new Image(
                  image: new AssetImage("mainframe_assets/images/powered_by_2x.png")
              )
          ),
          new Container(
            alignment: Alignment.center,
            //padding: const EdgeInsets.all(20.0),
            child: new Text(
                "version build 1.0.0",
                style: new TextStyle(fontSize: 12.0, color: Colors.white, fontFamily: "Montserrat-Light")
            ),
          ),
        ],
      ),
    );
  }
}