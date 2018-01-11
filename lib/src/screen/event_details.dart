import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';

class EventDetails extends StatefulWidget {
  @override
  _EventDetailsState createState() => new _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new MFAppBar("EVENT TITLE", context),
      body: new ListView(
        children: <Widget>[
          //new Expanded(
              /*child:*/ new Container(
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new ExactAssetImage("mainframe_assets/images/m7x5ba.jpg"),
                        fit: BoxFit.cover
                    )
                ),
                child: new Container(
                  height: 55.0,
                  width: 200.0,
                  child: new Text("Find Your Next Event Below",
                    style: new TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0
                    ),
                  ),
                ),
                height: 235.0,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
              ),
          //),

        ],
      ),
    );
  }
}