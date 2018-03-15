import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/screen/solo_management.dart' as soloMgt;
import 'package:myapp/src/screen/couple_management.dart' as coupleMgt;
import 'package:myapp/src/screen/event_registration.dart' as registration;

const int _timerDelay = 400;

class ShowTips {

  static bool isOpened = false;
  static TextStyle tStyle = new TextStyle(
      fontSize: 16.0,
      color: Colors.white,
      fontFamily: "Montserrat-Regular"
  );

  static Timer showTips(BuildContext context, String tip) {

    Timer periodic = new Timer(new Duration(milliseconds: _timerDelay), (){
      isOpened = true;
      if(global.hasTips) {
        switch(tip) {
          case 'registration':
            if(registration.participant == null) {
              showContentTips(context, "Event Registration Screen", false, [
                new Text("To add participants to this Event. Please Tap on "),
                new Text("Select Participant(s). ", style: new TextStyle(color: new Color(0xff00e5ff))),
              ]);
            } else {
              showContentTips(context, "Event Registration Screen", false, [
                new Text("Participant is now selected. You may now press the "),
                new Text("ADD TO EVENT ", style: new TextStyle(color: new Color(0xff00e5ff))),
                new Text("Button."),
              ]);
            }
            break;
          case 'registrationEntries':
            showContentTips(context, "Event Registration Screen", true, [
              new RichText(
                text: new TextSpan(
                  text: "To add participants to this Event. Please Tap on ",
                  style: tStyle,
                  children: <TextSpan>[
                    new TextSpan(text: "Select Participant(s). ", style: new TextStyle(color: new Color(0xff00e5ff))),
                  ]
                )
              )
            ]).then((val){
              showContentTips(context, "Event Participants", true, [
                new RichText(
                  text: new TextSpan(
                    text: "You may find a list of Participant(s) already added to the Event. You may press the ",
                    style: tStyle,
                    children: <TextSpan>[
                      new TextSpan(text: "Participant Entry Component ", style: new TextStyle(color: new Color(0xff00e5ff))),
                      new TextSpan(text: " to show a list of buttons."),
                    ]
                  ),
                )
              ]).then((_val2){
                showContentTips(context, "Event Participants", true, [
                  new RichText(
                    text: new TextSpan(
                      text: "The Buttons listed are the applicable Form Entries in this Event for the Participant.",
                      style: tStyle
                    )
                  )
                ]).then((_val3){
                  showContentTips(context, "Event Participants", false, [
                    new RichText(
                        text: new TextSpan(
                          text: "Please press the corresponding ",
                          style: tStyle,
                          children: <TextSpan>[
                            new TextSpan(text: "Form Entry Button ", style: new TextStyle(color: new Color(0xff00e5ff))),
                            new TextSpan(text: " you want the Participant to register to, before you can proceed to the Summary Screen"),
                          ]
                        )
                    )
                  ]);
                });
              });
            });
            break;
          case 'participantsList':
            showContentTips(context, "Participants List", false, [
              new Text("Please select a participant on the list below. Or you can create a New Participant with the add Participant Icon "),
              //new Text("Add Participant Icon ", style: new TextStyle(color: new Color(0xff00e5ff))),
              new Padding(padding: const EdgeInsets.symmetric(vertical: 5.0), child: new Icon(Icons.person_add, color: new Color(0xff00e5ff))),
              new Text(" at the bottom right corner"),
            ]);
            break;
          case 'addParticipant':
            showContentTips(context, "Add Participant Screen ", false, [
              new Text("To add/select a Participant, you may add them via Facebook, Contacts or Existing. Please Tap on their names or you can add a participant manually by pressing "),
              new Text("ADD MANUALLY ", style: new TextStyle(color: new Color(0xff00e5ff))),
              new Text("Button."),
            ]);
            break;
          case 'soloParticipant':
            if(soloMgt.participantUser == null) {
              showContentTips(context, "Solo Participant Management Screen", false, [
                new Text("To add Solo Participants to the list. Please Tap on "),
                new Text("ASSIGN",style: new TextStyle(color: new Color(0xff00e5ff)))
              ]);
            } else {
              showContentTips(context, "Solo Participant Management Screen", false, [
                new Text("A Solo Participant is now assigned. You may now hit "),
                new Text("ADD PARTICIPANT",style: new TextStyle(color: new Color(0xff00e5ff))),
                new Text(" Button."),
              ]);
            }
            break;
          case 'coupleParticipant':
            if(coupleMgt.couple1 == null || coupleMgt.couple2 == null) {
              showContentTips(context, "Couple Management Screen", false, [
                new Text("To add Couple to the list. Please Tap on "),
                new Text("ASSIGN",style: new TextStyle(color: new Color(0xff00e5ff)))
              ]);
            } else {
              showContentTips(context, "Couple Management Screen", false, [
                new Text("A Couple is now assigned. You may now hit "),
                new Text("ADD COUPLE",style: new TextStyle(color: new Color(0xff00e5ff))),
                new Text(" Button."),
              ]);
            }
            break;
          default:
            break;
        }
      }
    });
    return periodic;
  }

  static Future<Null> showContentTips(BuildContext context, String title, bool isNext, List<Widget> contents) async {
    if(global.hasTips) {
      return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        child: new AlertDialog(
          title: new Text(title),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Wrap(
                    children: contents
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.notifications_off),
                  new Text("Turn Off Tips")
                ],
              ),
              onPressed: () {
                _closeTipModal(context, btnVal: "off");
              },
            ),
            new FlatButton(
              child: new Wrap(
                children: <Widget>[
                  (isNext) ? new Container(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: new Text(
                          'Next', style: new TextStyle(fontSize: 16.0))
                  ) :
                  new Container(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: new Text(
                          'Continue', style: new TextStyle(fontSize: 16.0))
                  ),
                  (isNext) ? new Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: new Icon(Icons.arrow_forward_ios),
                  ) : new Container()
                ],
              ),
              onPressed: () {
                String btnVal = "continue";
                if (isNext)
                  btnVal = "next";

                _closeTipModal(context, btnVal: btnVal);
              },
            ),
          ],
        ),
      );
    }
  }

  static _closeTipModal(context, {String btnVal}) {
    isOpened = false;
    if(btnVal == null || btnVal.isEmpty) {
      Navigator.of(context).pop();
    } else {
      if(btnVal == "off") {
        global.hasTips = false;
        Navigator.of(context).pop();
        _displayOffTips(context);
      } else {
        Navigator.of(context).pop(btnVal);
      }
    }
  }

  static _displayOffTips(context) {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      child: new AlertDialog(
        title: new Text("Tips Turned Off"),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Wrap(
                children: <Widget>[
                  new Text("To enable this feature, you may press the Menu"),
                  //new Text("Menu ",style: new TextStyle(color: new Color(0xff00e5ff))),
                  new Icon(Icons.menu, color: new Color(0xff00e5ff)),
                  new Text("on the Main Screen, and press "),
                  new Text("Show Tips",style: new TextStyle(color: new Color(0xff00e5ff))),
                ]
              ),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Row(
              children: <Widget>[
                new Icon(Icons.lightbulb_outline),
                new Text("OK")
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}