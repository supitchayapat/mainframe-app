import 'dart:collection';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/model/EventEntry.dart';
import 'package:myapp/src/dao/EventEntryDao.dart';
import 'participant_list.dart' as participantList;
import 'event_registration.dart' as registration;

var formEntry;
var formParticipant;
var formData;
var formPushId;

class GroupDance extends StatefulWidget {
  @override
  _GroupDanceState createState() => new _GroupDanceState();
}

class _GroupDanceState extends State<GroupDance> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String titlePage = "";
  HashMap<String, String> _dataMap = new HashMap<String, String>();

  @override
  void initState() {
    super.initState();

    if (formEntry != null && formEntry.name != null) {
      titlePage = formEntry.name;
    }

    if(formData != null) {
      _dataMap = formData;
    }
  }

  Future _handleBackButton() async {
    if(formParticipant?.members != null) {
      var val = await showMainFrameDialogWithCancel(
          context, "Form Entry", "Save Changes on ${formEntry.name}?");
      if (val == "OK") {
        _handleSaving();
      }
      else {
        Navigator.of(context).maybePop();
      }
    }
  }

  void _handleSaving() {
    EventEntry entry = new EventEntry(
        formEntry: formEntry,
        event: registration.eventItem,
        participant: formParticipant,
        levels: [],
        danceEntries: 1,
        freeForm: _dataMap
    );
    if(formPushId != null) {
      EventEntryDao.updateEventEntry(formPushId, entry);
    } else {
      EventEntryDao.saveEventEntry(entry);
    }
    Navigator.of(context).maybePop();
  }

  List<Widget> _generateGroupMembers() {
    if(formParticipant?.members != null) {
      return formParticipant.members.map((member){
        return new Container(
          padding: const EdgeInsets.all(5.0),
          decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
              border: new Border.all(
                width: 2.0,
                color: const Color(0xFF313746),
                style: BorderStyle.solid,
              )
          ),
          child: new Wrap(
            children: <Widget>[
              new Text("${member.first_name} ${member.last_name}",
                style: new TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              new Padding(padding: const EdgeInsets.only(left: 4.0)),
              new InkWell(
                onTap: (){
                  setState((){formParticipant.members.remove(member);});
                },
                child: new Icon(Icons.cancel, color: Colors.black),
              )
            ],
          ),
        );
      }).toList();
    } else {
      return [new Text("Add Group Members", style: new TextStyle(fontSize: 17.0, color: Colors.black))];
    }
  }

  List<Widget> _generateInputs() {
    List<Widget> _children = [];
    var _dropValue = "SUMMARY";

    if(formEntry?.structure?.verticals != null) {
      formEntry.structure.verticals.forEach((_vert){
        //print(_vert?.toJson());
        var _formLookup = formEntry.getFormLookup(_vert.link);
        //print(_formLookup?.description);
        if(_formLookup?.description != null) {
          String _idx = _formLookup.description.toString().toLowerCase().replaceAll(" ", "_");
          _dataMap.putIfAbsent(_idx, () => _formLookup?.elements[0]?.content);
          List<String> _elementItems = [];

          _formLookup?.elements?.forEach((_elem){
            _elementItems.add(_elem.content);
          });
          //print(_elementItems);

          _children.add(new Container(
            //color: Colors.amber,
            margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
            child: new Text(
                _formLookup?.description, style: new TextStyle(fontSize: 18.0)),
          ));
          if(_elementItems.length > 1) {
            _children.add(new Theme(
                data: new ThemeData(
                    brightness: Brightness.light
                ),
                child: new DropdownButtonHideUnderline(
                    child: new Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        color: Colors.white,
                        child: new DropdownButton(
                            iconSize: 30.0,
                            value: _dataMap[_idx],
                            items: _elementItems.map((String value) {
                              return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value));
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                if (val != null)
                                  _dataMap[_idx] = val;
                              });
                            }
                        )
                    )
                )
            ));
          } else if(_elementItems.length == 1) {
            _children.add(new Container(
              //color: Colors.amber,
              margin: const EdgeInsets.only(top: 10.0, bottom: 5.0),
              child: new Text(
                  " - ${_elementItems[0]}", style: new TextStyle(fontSize: 18.0)),
            ));
          }
        }
      });
      return _children;
    } else {
      return _children;
    }
  }

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/add_via_email.png";
    List<Widget> _children = [];
    _children.add(new MaterialButton(
      padding: const EdgeInsets.all(0.0),
      onPressed: (){
        participantList.participantType = "group";
        Navigator.of(context).pushNamed("/addPartner");
      },
      child: new Container(
          constraints: const BoxConstraints(minHeight: 50.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
              border: new Border.all(
                width: 2.0,
                color: const Color(0xFF313746),
                style: BorderStyle.solid,
              ),
              color: Colors.white
          ),
          child: new Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                  child: new Wrap(
                    spacing: 4.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    children: _generateGroupMembers(),
                  ),
                ),
                new Icon(Icons.person_add, color: Colors.black),
              ],
            ),
          )
      ),
    ));

    // generate inputs
    _children.addAll(_generateInputs());

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new MFAppBar(titlePage, context, backButtonFunc: _handleBackButton),
      body: new Form(
          key: _formKey,
          child: new ListView(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            children: _children,
          )
      ),
      floatingActionButton: new InkWell(
        onTap: () {
          _handleSaving();
        },
        child: new Container(
          //color: Colors.amber,
          width: 100.0,
          height: 40.0,
          alignment: Alignment.center,
          decoration: new BoxDecoration(
            image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
          ),
          child: new Text("Save Entry", style: new TextStyle(fontSize: 17.0)),
        ),
      )
    );
  }
}