import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/model/EventEntry.dart';
import 'package:myapp/src/dao/EventEntryDao.dart';
import 'event_registration.dart' as registration;

var formEntry;
var formParticipant;
var formData;
var formPushId;
var freeFormObj;

class entry_freeform extends StatefulWidget {
  @override
  _entry_freeformState createState() => new _entry_freeformState();
}

class _entry_freeformState extends State<entry_freeform> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String titlePage = "";

  @override
  void initState() {
    super.initState();

    if(formEntry != null && formEntry.name != null) {
      titlePage = formEntry.name;
    }

    if(formData != null) {
      freeFormObj = formData;
    }
  }

  Future _handleBackButton() async {
    var val = await showMainFrameDialogWithCancel(
        context, "Form Entry", "Save Changes on ${formEntry.name}?");
    if (val == "OK") {
      _handleSaving();
    }
    else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleSaving() {
    final FormState form = _formKey.currentState;
    if(!form.validate()){
      showInSnackBar(_scaffoldKey, 'Please fix the errors in red before submitting.');
    }
    else {
      form.save();
      bool hasValue = false;
      freeFormObj.toJson().forEach((key, val) {
        if(val != null) {
          hasValue = true;
          //print(val);
        }
      });
      if(hasValue) {
        EventEntry entry = new EventEntry(
          formEntry: formEntry,
          event: registration.eventItem,
          participant: formParticipant,
          levels: [],
          danceEntries: 1,
          freeForm: freeFormObj
        );
        if(formPushId != null) {
          EventEntryDao.updateEventEntry(formPushId, entry);
        } else {
          EventEntryDao.saveEventEntry(entry);
        }
        Navigator.of(context).maybePop();
      }
      else {
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/add_via_email.png";
    List<Widget> _children = [];
    _children.add(freeFormObj.toWidget());

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