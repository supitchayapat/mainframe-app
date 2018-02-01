import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';

class couple_management extends StatefulWidget {
  @override
  _couple_managementState createState() => new _couple_managementState();
}

class _couple_managementState extends State<couple_management> {
  String _dropValue = "COUPLE";
  List<String> _listItems = [];

  void _handleAddCouple() {
    setState(() {
      _listItems.add(_dropValue);
    });
  }

  Widget _generateItem(val) {
    Widget _entryChild;

    _entryChild = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Expanded(child: new Text(val, style: new TextStyle(fontSize: 16.0, color: Colors.black))),
        new Container(
          width: 25.0,
          child: new Icon(Icons.keyboard_arrow_right, color: Colors.black),
        )
      ],
    );

    return new InkWell(
      onTap: (){
        /*setState((){
          if(!entry.toggle)
            entry.toggle = true;
          else
            entry.toggle = false;
        });*/
      },
      child: new Container(
        decoration: new BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
        height: 55.0,
        child: _entryChild,
      ),
    );
  }

  Widget _generateInputContainer() {
    //if(_dropValue == "COUPLE") {
      return new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 10.0),
              child: new Text("Assign Couple", style: new TextStyle(fontSize: 16.0)),
            ),
            new Container(
              padding: const EdgeInsets.only(top: 10.0),
              child: new Row(
                children: <Widget>[
                  new Text("Name:", style: new TextStyle(fontSize: 16.0)),
                  new Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    decoration: new BoxDecoration(
                        borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                        border: new Border.all(
                          width: 2.0,
                          color: const Color(0xFF313746),
                          style: BorderStyle.solid,
                        )
                    ),
                    child: new MaterialButton(
                      padding: const EdgeInsets.all(5.0),
                      minWidth: 5.0, height: 5.0,
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pushNamed("/addPartner");
                      },
                      child: new Text("ASSIGN",
                        style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            new Container(
              padding: const EdgeInsets.only(top: 10.0),
              child: new Row(
                children: <Widget>[
                  new Text("Name:", style: new TextStyle(fontSize: 16.0)),
                  new Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    decoration: new BoxDecoration(
                        borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                        border: new Border.all(
                          width: 2.0,
                          color: const Color(0xFF313746),
                          style: BorderStyle.solid,
                        )
                    ),
                    child: new MaterialButton(
                      padding: const EdgeInsets.all(5.0),
                      minWidth: 5.0, height: 5.0,
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pushNamed("/addPartner");
                      },
                      child: new Text("ASSIGN",
                        style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            new Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 10.0, bottom: 0.0),
              child: new MainFrameButton(
                child: new Text("ADD COUPLE"),
                onPressed: (){ },
              ),
            ),
          ],
        ),
      );
    //}
    /*else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 10.0),
              child: new Text("Assign Group Members", style: new TextStyle(fontSize: 16.0)),
            ),
            new Container(
              padding: const EdgeInsets.only(top: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: new Text("Group Name:", style: new TextStyle(fontSize: 16.0)),
                  ),
                  new Expanded(
                    child: new Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      /*decoration: new BoxDecoration(
                        borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                        color: Colors.white
                      ),*/
                      child: new TextFormField(),
                    ),
                  )
                ],
              ),
            ),
            new Container(
              padding: const EdgeInsets.only(top: 10.0),
              child: new Row(
                children: <Widget>[
                  new Text("Members (0):", style: new TextStyle(fontSize: 16.0)),
                  new Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    decoration: new BoxDecoration(
                        borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                        border: new Border.all(
                          width: 2.0,
                          color: const Color(0xFF313746),
                          style: BorderStyle.solid,
                        )
                    ),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new MaterialButton(
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                          minWidth: 2.0, height: 5.0,
                          color: const Color(0xFFC5CDDF),
                          onPressed: (){
                            Navigator.pop(context, "CANCEL");
                          },
                          child: new Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                            child: new Text("SHOW"),
                          ),
                        ),
                        new MaterialButton(
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                          minWidth: 35.0, height: 5.0,
                          color: Colors.white,
                          onPressed: (){
                            Navigator.pop(context, "OK");
                          },
                          child: new Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                            child: new Text("ADD", style: new TextStyle(color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {
    Widget _inputContainer = _generateInputContainer();

    return new Scaffold(
      appBar: new MFAppBar("COUPLE MANAGEMENT", context),
      body: new Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            decoration: new BoxDecoration(
              border: const Border(
                top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                //bottom: const BorderSide(width: 1.0, color: Colors.black)
              ),
            ),
            child: new Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
              decoration: new BoxDecoration(
                border: const Border(
                  top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                  //bottom: const BorderSide(width: 1.0, color: Colors.white)
                ),
              ),
              child: new Column(
                children: <Widget>[
                  _inputContainer
                ],
              ),
            ),
          ),
          new Container(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            decoration: new BoxDecoration(
              border: const Border(
                top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
              ),
            ),
            child: new Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 0.0),
              decoration: new BoxDecoration(
                border: const Border(
                  top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                ),
              ),
            ),
          ),
          new Flexible(
            child: new ListView(
              children: _listItems.map((val){
                return _generateItem(val);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}