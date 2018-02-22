import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';

var participantUser;

class solo_management extends StatefulWidget {
  @override
  _solo_managementState createState() => new _solo_managementState();
}

class _solo_managementState extends State<solo_management> {
  List<String> _listItems = [];
  Map<String, User> _solos = {};
  var soloListener;

  @override
  void initState() {
    super.initState();

    soloParticipantsListener((users){
      setState(() {
        _solos = {};
        _listItems = [];
        users.forEach((val){
          _listItems.add("${val.first_name} ${val.last_name}");
          _solos.putIfAbsent("${val.first_name} ${val.last_name}", () => val);
        });
      });
    }).then((listener) {soloListener = listener;});
  }

  @override
  void dispose() {
    super.dispose();
    soloListener.cancel();
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
                if(_solos.containsKey(val))
                  removeSoloParticipant(_solos[val]);
              }
          ),
        )
      ],
    );

    return new InkWell(
      onTap: (){
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
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 10.0),
            child: new Text("Participant", style: new TextStyle(fontSize: 18.0)),
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
                      //couple1 = "_assignCoupleParticipant";
                      Navigator.of(context).pushNamed("/addPartner");
                    },
                    child: new Text((participantUser == null || participantUser is String) ? "ASSIGN" : "${participantUser.first_name} ${participantUser.last_name}",
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
              child: new Text("ADD PARTICIPANT"),
              onPressed: (){
                if(participantUser != null) {
                  if(!_listItems.contains("${participantUser.first_name} ${participantUser.last_name}"))
                    saveUserSoloParticipants(participantUser);
                  else
                    print("FAIL ADD");
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
  }

  @override
  Widget build(BuildContext context) {
    Widget _inputContainer = _generateInputContainer();

    return new Scaffold(
      appBar: new MFAppBar("SOLO PARTICIPANT MANAGEMENT", context),
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