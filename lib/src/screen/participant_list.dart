import 'package:flutter/material.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/screen/event_registration.dart' as registration;

var participantType;

class participant_list extends StatefulWidget {
  @override
  _participant_listState createState() => new _participant_listState();
}

class _participant_listState extends State<participant_list> {
  TextEditingController _searchCtrl = new TextEditingController();
  List _solo = [];
  List _couples = [];
  Map<String, dynamic> _users = {};
  var soloListener;
  var coupleListener;

  @override
  void initState() {
    super.initState();

    soloParticipantsListener((users){
      //print("NUMBER OF USERS: ${users.length}");
      setState((){
        _users = {};
        _solo = [];
        _solo.addAll(users);
        users.forEach((val){
          _users.putIfAbsent("${val.first_name} ${val.last_name}", () => val);
        });
        _couples.forEach((val){
          _users.putIfAbsent("${val.coupleName}", () => val);
        });
      });
    }).then((listener) {soloListener=listener;});

    coupleParticipantsListener((couples){
      //print("NUMBER OF USERS: ${couples.length}");
      setState((){
        _users = {};
        _couples = [];
        _couples.addAll(couples);
        _solo.forEach((val){
          _users.putIfAbsent("${val.first_name} ${val.last_name}", () => val);
        });
        couples.forEach((val){
          _users.putIfAbsent("${val.coupleName}", () => val);
        });
      });
    }).then((listener){coupleListener=listener;});
  }

  @override
  void dispose() {
    super.dispose();
    soloListener.cancel();
    coupleListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _participants = [];
    _participants.add(new Container(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      decoration: new BoxDecoration(
        border: const Border(
          top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
          //bottom: const BorderSide(width: 1.0, color: Colors.black)
        ),
      ),
      child: new Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0),
        decoration: new BoxDecoration(
          border: const Border(
            top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
            //bottom: const BorderSide(width: 1.0, color: Colors.white)
          ),
        ),
      ),
    ));
    //_participants.addAll(
        _users.forEach((key, val){
          _participants.add(new InkWell(
            onTap: () {
              setState((){
                registration.participant = {
                  "name": key,
                  "user": val
                };
              });
              Navigator.of(context).maybePop();
            },
            child: new Container(
              padding: const EdgeInsets.symmetric(vertical: 1.0),
              decoration: new BoxDecoration(
                border: const Border(
                    bottom: const BorderSide(width: 1.0, color: const Color(0xFF53617C))
                ),
              ),
              child: new Container(
                padding: const EdgeInsets.only(left: 50.0, right: 20.0, bottom: 10.0, top: 10.0),
                decoration: new BoxDecoration(
                  border: const Border(
                      bottom: const BorderSide(width: 2.0, color: const Color(0xFF212D44))
                  ),
                ),
                child: new Text("${key}", style: new TextStyle(fontSize: 18.0)),
              ),
            ),
          ));
        });
    //);
    _participants.add(new InkWell(
      onTap: () {
        participantType = "solo";
        Navigator.of(context).pushNamed("/addPartner");
      },
      child: new Container(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        decoration: new BoxDecoration(
          border: const Border(
              bottom: const BorderSide(width: 1.0, color: const Color(0xFF53617C))
          ),
        ),
        child: new Container(
          padding: const EdgeInsets.only(left: 50.0, right: 20.0, bottom: 10.0, top: 10.0),
          decoration: new BoxDecoration(
            border: const Border(
                bottom: const BorderSide(width: 2.0, color: const Color(0xFF212D44))
            ),
          ),
          child: new Text("Create New Solo Participant ...", style: new TextStyle(fontSize: 18.0)),
        ),
      ),
    ));
    _participants.add(new InkWell(
      onTap: () {
        participantType = "couple";
        Navigator.of(context).pushNamed("/coupleManagement");
      },
      child: new Container(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        decoration: new BoxDecoration(
          border: const Border(
              bottom: const BorderSide(width: 1.0, color: const Color(0xFF53617C))
          ),
        ),
        child: new Container(
          padding: const EdgeInsets.only(left: 50.0, right: 20.0, bottom: 10.0, top: 10.0),
          decoration: new BoxDecoration(
            border: const Border(
                bottom: const BorderSide(width: 2.0, color: const Color(0xFF212D44))
            ),
          ),
          child: new Text("Create New Couple Participant...", style: new TextStyle(fontSize: 18.0)),
        ),
      ),
    ));


    return new Scaffold(
      appBar: new AppBar(
        titleSpacing: 0.0,
        title: new Theme(
            data: new ThemeData(
              brightness: Brightness.dark
            ),
            child: new Container(
              //color: Colors.amber,
              height: 80.0,
              child: new Row(
                children: <Widget>[
                  new IconButton(icon: new Icon(Icons.arrow_back_ios), onPressed: (){Navigator.of(context).maybePop();}),
                  new Expanded(
                      child: new Container(
                        decoration: new BoxDecoration(
                            borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                            border: new Border.all(
                              width: 2.0,
                              color: const Color(0xFF313746),
                              style: BorderStyle.solid,
                            ),
                            color: Colors.white
                        ),
                        child: new Row(
                          children: <Widget>[
                            new Padding(padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                              child: new Icon(Icons.search, color: Colors.black),
                            ),
                            new Expanded(
                                child: new Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: new TextField(
                                    controller: _searchCtrl,
                                    decoration: new InputDecoration(
                                      hideDivider: true,
                                      hintText: "Search Name",
                                      hintStyle: new TextStyle(color: Colors.black)
                                    ),
                                    style: new TextStyle(color: Colors.black, fontSize: 18.0, fontFamily: "Montserrat-Regular"),
                                  ),
                                )
                            )
                          ],
                        ),
                      )
                  )
                ],
              ),
            ),
        ),
        automaticallyImplyLeading: false
      ),
      body: new ListView(
        children: _participants,
      ),
    );
  }
}