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
              showContentTips(context, "Event Registration", false, [
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
            showContentTips(context, "Event Registration", true, [
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
              if(val != "cancel") {
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
                  if(_val2 != "cancel") {
                    showContentTips(context, "Event Participants", true, [
                      new RichText(
                          text: new TextSpan(
                              text: "The Buttons listed are the applicable Form Entries in this Event for the Participant.",
                              style: tStyle
                          )
                      )
                    ]).then((_val3){
                      if(_val3 != "cancel") {
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
                      }
                    });
                  }
                });
              }
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
        barrierDismissible: true, // user must tap button!
        child: new AlertDialog(
          title: new Container(
            //color: Colors.amber,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Expanded(child: new Text(title)),
                /*new InkWell(
                  onTap: (){
                    //Navigator.popUntil(context, ModalRoute.withName("/registration"));
                    _closeTipModal(context, btnVal: "cancel");
                  },
                  child: new Icon(Icons.cancel),
                )*/
              ],
            )
          ),
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
            new MaterialButton(
              child: new Container(
                //color: Colors.amber,
                child: new Row(
                  children: <Widget>[
                    new Icon(Icons.notifications_off),
                    new Text("Turn Off" + (!isNext ? " Tips": ""), style: new TextStyle(fontSize: 16.0))
                  ],
                ),
              ),
              onPressed: () {
                _closeTipModal(context, btnVal: "off");
              },
            ),
            (isNext) ? new InkWell(
              onTap: (){
                _closeTipModal(context, btnVal: "cancel");
              },
              child: new Container(
                child: new Text("Close", style: new TextStyle(fontSize: 16.0)),
              ),
            ) : new Container(),
            new MaterialButton(
              child: new Wrap(
                children: <Widget>[
                  (isNext) ? new Container(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: new Text(
                          'More', style: new TextStyle(fontSize: 16.0))
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
      switch(btnVal) {
        case 'off':
          global.hasTips = false;
          Navigator.of(context).pop();
          _displayOffTips(context);
          break;
        case 'cancel':
          Navigator.of(context).pop("cancel");
          break;
        default:
          Navigator.of(context).pop(btnVal);
          break;
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