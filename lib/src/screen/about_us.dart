import 'dart:convert' show JSON;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => new _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  String _appVersion = "";
  String _internalBuild = "";

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('mainframe_assets/conf/config.json').then<Null>((String data) {
      var result = JSON.decode(data);
      String internal_build = result['internal_build'];
      String app_version = result['app_version'];
      //print("JSON has "+ internal_build +" internal_build");
      setState((){
        _appVersion = app_version;
        _internalBuild = internal_build;
      });
    });
  }

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
            child: new Column(
              children: <Widget>[
                new Text(
                    "app ver "+_appVersion,
                    style: new TextStyle(fontSize: 12.0, color: Colors.white, fontFamily: "Montserrat-Light")
                ),
                new Text(
                    "internal build: "+_internalBuild,
                    style: new TextStyle(fontSize: 12.0, color: Colors.white, fontFamily: "Montserrat-Light")
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}