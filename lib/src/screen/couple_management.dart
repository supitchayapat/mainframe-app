import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/dao/UserDao.dart';

var couple1;
var couple2;

class couple_management extends StatefulWidget {
  @override
  _couple_managementState createState() => new _couple_managementState();
}

class _couple_managementState extends State<couple_management> {
  String _dropValue = "COUPLE";
  List<String> _listItems = [];
  Map<String, List> _couples = {};
  var coupleListener;

  @override
  void initState() {
    super.initState();

    coupleParticipantsListener((couples){
      //print("NUMBER OF USERS: ${couples.length}");
      setState((){
        _couples = {};
        _listItems = [];
        //_couples.addAll(couples);
        couples.forEach((val){
          //_users.putIfAbsent("${val.coupleName}", () => "couple");
          _listItems.add("${val.coupleName}");
          _couples.putIfAbsent(val.coupleName, () => val.couple);
        });
      });
    }).then((listener) {coupleListener = listener;});
  }

  @override
  void dispose() {
    super.dispose();
    coupleListener.cancel();
  }

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
        new Expanded(
            child: new Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: new Text(val, style: new TextStyle(fontSize: 16.0, color: Colors.black)),
            )
        ),
        new Container(
          //color: Colors.amber,
          width: 35.0,
          child: new IconButton(
              icon: new Icon(Icons.cancel, color: Colors.black),
              onPressed: (){
                List usrs = _couples[val];
                removeUserCoupleParticipants(usrs[0], usrs[1]);
              }
          ),
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
              child: new Text("Assign Couple", style: new TextStyle(fontSize: 18.0)),
            ),
            new Container(
              padding: const EdgeInsets.only(top: 10.0),
              child: new Row(
                children: <Widget>[
                  new Text("Name:", style: new TextStyle(fontSize: 17.0)),
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
                      padding: const EdgeInsets.all(7.0),
                      minWidth: 5.0, height: 5.0,
                      color: Colors.white,
                      onPressed: () {
                        couple1 = "_assignCoupleParticipant";
                        Navigator.of(context).pushNamed("/addPartner");
                      },
                      child: new Text((couple1 == null || couple1 is String) ? "ASSIGN" : "${couple1.first_name} ${couple1.last_name}",
                        style: new TextStyle(
                            fontSize: 17.0,
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
                  new Text("Name:", style: new TextStyle(fontSize: 17.0)),
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
                      padding: const EdgeInsets.all(7.0),
                      minWidth: 5.0, height: 5.0,
                      color: Colors.white,
                      onPressed: () {
                        couple2 = "_assignCoupleParticipant";
                        Navigator.of(context).pushNamed("/addPartner");
                      },
                      child: new Text((couple2 == null || couple2 is String) ? "ASSIGN" : "${couple2.first_name} ${couple2.last_name}",
                        style: new TextStyle(
                            fontSize: 17.0,
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
                onPressed: (){
                  if(couple1 != null && couple2 != null) {
                    saveUserCoupleParticipants(couple1, couple2);
                  }
                  else {
                    print("FAIL ADD");
                  }
                },
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