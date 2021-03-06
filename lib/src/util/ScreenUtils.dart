import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//import 'package:facebook_sign_in/facebook_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:myapp/src/model/FormAgeCat.dart';
import 'package:url_launcher/url_launcher.dart';

/*
  Author: Art

  The dart file contains Screen utility methods

  ShowInSnackBar is a method that shows snackbar
  that accepts a string value to show
 */
void showInSnackBar(GlobalKey<ScaffoldState> _scaffoldKey, String value) {
  _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value)
  ));
}

/*
  Facebook Share Dialog
 */
void showFacebookAppShareDialog() {
  //FacebookSignIn.shareDialog();
}

/*
  A method that shows a dialog screen
  that accepts a String message and a string title
 */
Future<Null> showMainFrameDialog(BuildContext context, String title, String msg, {String uriRedirect}) async {

  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    child: new AlertDialog(
      title: new Text(title),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(msg)
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('OK'),
          onPressed: () {
            if(uriRedirect == null) {
              Navigator.pop(context);
            } else {
              canLaunch(uriRedirect).then((canLaunch){
                if(canLaunch) {
                  launch(uriRedirect).then((nil){
                    exit(0);
                  });
                } else {
                  exit(0);
                }
              });
            }
          },
        ),
      ],
    ),
  );
}

/*
  A method that shows a dialog screen
  that accepts a String message and a string title
 */
Future<Null> showDialogResult(BuildContext context, String title, {List headerItems, List markItems}) async {
  List<Widget> _headers = [];
  List<Widget> _marks = [];
  headerItems.forEach((item){
    _headers.add(
        new Flexible(
          child: new Container(
            constraints: new BoxConstraints(minWidth: 60.0, minHeight: 20.0),
            child: new Text(item),
          ),
        )
    );
  });
  markItems.forEach((item){
    _marks.add(
        new Flexible(
          child: new Container(
            constraints: new BoxConstraints(minWidth: 60.0, minHeight: 20.0),
            child: new Text(item),
          ),
        )
    );
  });


  return showDialog(
    context: context,
    child: new Dialog(
      child: new Container(
        decoration: new BoxDecoration(
            borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
            color: new Color(0xff364864),
            boxShadow: <BoxShadow>[
              new BoxShadow(
                  blurRadius: 1.0,
                  spreadRadius: 1.0
              )
            ]
        ),
        height: 220.0,
        width: 180.0,
        constraints: new BoxConstraints(minHeight: 220.0, maxHeight: 390.0),
        child: new Column(
          children: <Widget>[
            new Container(
              //color: Colors.amber,
              height: 45.0,
              child: new Row(
                children: <Widget>[
                  new Flexible(
                    child: new Center(
                      child: new Text(title, overflow: TextOverflow.ellipsis, style: new TextStyle(fontSize: 16.0)),
                    )
                  ),
                ],
              ),
            ),
            new Container(
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              color: new Color(0xFF212D44),
              child: new Row(
                children: _headers,
              )
            ),
            new Container(
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: new Row(
                  children: _marks,
                )
            ),
          ],
        ),
      ),
    )
  );
}

Future<dynamic> showSelectionDialog(BuildContext context, String titleMsg, double height, Map<String, dynamic> options) async {
  List<Widget> _opts = [];

  options?.forEach((_key, _val){
    _opts.add(new Row(
      children: <Widget>[
        new Expanded(
          child: new MaterialButton(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              onPressed: (){
                Navigator.of(context).pop(_val);
              },
              child: new Container(
                decoration: new BoxDecoration(
                  borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                  color: new Color(0xff335577),
                ),
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0),
                child: new Center(child: new Text(_key)),
                alignment: Alignment.centerLeft,
              )
          ),
        ),
      ],
    ));
  });

  return showDialog<dynamic>(
      context: context,
      //barrierDismissible: false,
      child: new Dialog(
        child: new Container(
            decoration: new BoxDecoration(
                borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                color: new Color(0xff364864),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                      blurRadius: 1.0,
                      spreadRadius: 1.0
                  )
                ]
            ),
            height: height,
            width: 180.0,
            constraints: new BoxConstraints(minHeight: 220.0, maxHeight: 390.0),
            child: new Column(
              children: <Widget>[
                new Container(
                  //color: Colors.amber,
                  height: 45.0,
                  child: new Row(
                    children: <Widget>[
                      /*new Container(
                          margin: const EdgeInsets.only(left: 5.0),
                          child: new InkWell(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            child: new Icon(Icons.arrow_back_ios),
                          )
                      ),*/
                      new Flexible(
                          child: new Center(
                            child: new Text(titleMsg, overflow: TextOverflow.ellipsis, style: new TextStyle(fontSize: 16.0)),
                          )
                      ),
                    ],
                  ),
                ),
                new Expanded(
                  child: new Container(
                    //color: Colors.amber,
                    child: new ListView(
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            new Expanded(
                                child: new Container(
                                  width: 155.0,
                                  constraints: const BoxConstraints(minWidth: 55.0),
                                  child: new Column(
                                    children: _opts,
                                  ),
                                )
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        )
                      ],
                    ),
                  )
                )
              ],
            )
        ),
      )
  );
}

Future<String> showSummaryDialog(BuildContext context) async {
  double _scrWidth = MediaQuery.of(context).size.width;

  return showDialog<String>(
    context: context,
    barrierDismissible: true, // user must tap button!
    child: new Theme(
        // Dialog Theme
        data: new ThemeData(
          brightness: Brightness.light,
        ),
        // body
        child: new SimpleDialog(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                color: Colors.white,
              ),
              height: (MediaQuery.of(context).orientation == Orientation.portrait) ? 466.0 : 300.0,
              width: 340.0,
              child: new Column(
                children: <Widget>[
                  new Text("Session SUMMARY",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        height: 1.5,
                        fontSize: 16.0,
                        color: const Color(0xff000a12,
                        )
                    ),
                  ),

                  new Container(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: new Divider(color: Colors.black, height: 16.0)
                  ),

                  new Container(
                    //color: Colors.amber,
                    child: new Row(
                      children: <Widget>[
                        new Container(
                          //color: Colors.cyan,
                          width: (MediaQuery.of(context).orientation == Orientation.portrait) ? _scrWidth * 0.6 : 340.0 * 0.8,
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              new Container(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Text(
                                      "FRIDAY",
                                      style: new TextStyle(
                                        fontSize: 16.0,
                                        color: const Color(
                                          (0xff000a12),
                                        ),
                                      ),
                                    ),
                                    new Text(
                                      "July 21, 2017",
                                      style: new TextStyle(
                                        fontSize: 12.0,
                                        color: const Color(
                                          (0xff000a12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              new Padding(padding: const EdgeInsets.only(left: 10.0)),
                              new Container(
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Text("ALL DAY",
                                      style: new TextStyle(
                                        fontSize: 16.0,
                                        color: const Color(
                                          (0xff000a12),
                                        ),
                                      ),
                                    ),
                                    new Text(
                                      "with dinner",
                                      style: new TextStyle(
                                        fontSize: 12.0,
                                        color: const Color(
                                          (0xff000a12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              new Padding(padding: const EdgeInsets.only(left: 5.0)),
                              new Container(
                                child: new Row(
                                  children:<Widget>[
                                    new Image.asset("mainframe_assets/images/sun_a60.jpg",
                                      width: 16.0,
                                      height: 16.0,
                                    ),

                                    new Container(
                                      padding: new EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                                      child: new Image.asset("mainframe_assets/images/moon_a60.png",
                                        width: 16.0,
                                        height: 16.0,
                                      ),
                                    ),

                                    new Container(
                                      padding: new EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                                      child: new Image.asset("mainframe_assets/images/food_a60.png",
                                        width: 16.0,
                                        height: 16.0,
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        new Expanded(
                          //padding: const EdgeInsets.all(5.0),
                          child: new Container(
                            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            decoration: new BoxDecoration(
                                borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                                border: new Border.all(
                                  width: 2.0,
                                  color: const Color(0xFF313746),
                                  style: BorderStyle.solid,
                                ),
                                //color: Colors.green
                            ),
                            height: 40.0,
                            //color: Colors.green,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Text("Total", style: new TextStyle(color: const Color(0xFF778198))),
                                new Text("26", style: new TextStyle(color: const Color(0xFF313746), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  new Container(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: new Divider(color: Colors.black, height: 16.0)
                  ),

                  new Flexible(
                      child: new ListView(
                        children: <Widget>[
                          new Column(
                            children: <Widget>[
                              new Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 10.0),
                                child: new Text("John Doe (21 TICKETS)"),
                              ),

                              new Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("GENERAL ADMISSION", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                      ),
                                      new Expanded(
                                          child: new Container(
                                            //color: Colors.cyan,
                                            alignment: Alignment.centerRight,
                                            child: new Text("11"),
                                          )
                                      )
                                    ],
                                  )
                              ),

                              new Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("STANDING ROOM", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                      ),
                                      new Expanded(
                                          child: new Container(
                                            //color: Colors.cyan,
                                            alignment: Alignment.centerRight,
                                            child: new Text("1"),
                                          )
                                      )
                                    ],
                                  )
                              ),

                              new Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("RISERS", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                      ),
                                      new Expanded(
                                          child: new Container(
                                            //color: Colors.cyan,
                                            alignment: Alignment.centerRight,
                                            child: new Text("1"),
                                          )
                                      )
                                    ],
                                  )
                              ),

                              new Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("VIP ENTIRE TABLE (Seats 8)", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                      ),
                                      new Expanded(
                                          child: new Container(
                                            //color: Colors.cyan,
                                            alignment: Alignment.centerRight,
                                            child: new Text("1"),
                                          )
                                      )
                                    ],
                                  )
                              ),

                              new Container(
                                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 2.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("[Seats assigned to others: 2", style: new TextStyle(color: const Color(0xFF778198))),
                                      ),
                                    ],
                                  )
                              ),

                              new Container(
                                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 5.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("Assigned to JD: 6]", style: new TextStyle(color: const Color(0xFF778198))),
                                      ),
                                      new Container(
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
                                          onPressed: () {},
                                          child: new Text("ASSIGN SEATS",
                                            style: new TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.black
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                              ),

                              new Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                child: new Text("Jane Smith (0 TICKETS)"),
                              ),

                              new Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("No tickets Purchased or Assigned", style: new TextStyle(color: const Color(0xFF778198))),
                                      ),
                                    ],
                                  )
                              ),

                              new Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                                child: new Text("Georgette Sumpter (5 TICKETS)"),
                              ),

                              new Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("1ST ROW TABLE", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                      ),
                                      new Expanded(
                                          child: new Container(
                                            //color: Colors.cyan,
                                            alignment: Alignment.centerRight,
                                            child: new Text("3"),
                                          )
                                      )
                                    ],
                                  )
                              ),

                              new Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("VIP ENTIRE TABLE (Single Seat)", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                      ),
                                      new Expanded(
                                          child: new Container(
                                            //color: Colors.cyan,
                                            alignment: Alignment.centerRight,
                                            child: new Container(),
                                          )
                                      )
                                    ],
                                  )
                              ),

                              new Container(
                                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0),
                                  //color: Colors.amber,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: new Text("[Assigned from John Doe: 2]", style: new TextStyle(color: const Color(0xFF778198))),
                                      ),
                                    ],
                                  )
                              ),

                              new Container(
                                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                  child: new Divider(color: Colors.black, height: 16.0)
                              ),

                              new Center(
                                child: new Container(
                                  decoration: new BoxDecoration(
                                      borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                                      border: new Border.all(
                                        width: 2.0,
                                        color: const Color(0xFF313746),
                                        style: BorderStyle.solid,
                                      )
                                  ),
                                  child: new MaterialButton(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                    minWidth: 5.0, height: 5.0,
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context, "OK");
                                    },
                                    child: new Text("OK",
                                      style: new TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                  ),
                ],
              ),
            )
          ],
        ),
    ),
  );
}

Future<String> showTicketDialog(BuildContext context, String _name) async {
  double _scrWidth = MediaQuery.of(context).size.width;

  return showDialog<Null>(
    context: context,
    barrierDismissible: true,
    child: new Theme(
      // Dialog Theme
      data: new ThemeData(
        brightness: Brightness.light,
      ),
      // body
      child: new SimpleDialog(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
              color: Colors.white,
            ),
            height: (MediaQuery.of(context).orientation == Orientation.portrait) ? 466.0 : 300.0,
            width: 340.0,
            child: new Column(
              children: <Widget>[
                new Text(_name,
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      height: 1.5,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff000a12,
                      )
                  ),
                ),

                new Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Divider(color: Colors.black, height: 16.0)
                ),

                new Container(
                  //color: Colors.amber,
                  child: new Row(
                    children: <Widget>[
                      new Container(
                        //color: Colors.cyan,
                        width: (MediaQuery.of(context).orientation == Orientation.portrait) ? _scrWidth * 0.6 : 340.0 * 0.8,
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new Container(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text(
                                    "FRIDAY",
                                    style: new TextStyle(
                                      fontSize: 16.0,
                                      color: const Color(
                                        (0xff000a12),
                                      ),
                                    ),
                                  ),
                                  new Text(
                                    "July 21, 2017",
                                    style: new TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(
                                        (0xff000a12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            new Padding(padding: const EdgeInsets.only(left: 10.0)),
                            new Container(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("ALL DAY",
                                    style: new TextStyle(
                                      fontSize: 16.0,
                                      color: const Color(
                                        (0xff000a12),
                                      ),
                                    ),
                                  ),
                                  new Text(
                                    "with dinner",
                                    style: new TextStyle(
                                      fontSize: 12.0,
                                      color: const Color(
                                        (0xff000a12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            new Padding(padding: const EdgeInsets.only(left: 5.0)),
                            new Container(
                              child: new Row(
                                children:<Widget>[
                                  new Image.asset("mainframe_assets/images/sun_a60.jpg",
                                    width: 16.0,
                                    height: 16.0,
                                  ),

                                  new Container(
                                    padding: new EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                                    child: new Image.asset("mainframe_assets/images/moon_a60.png",
                                      width: 16.0,
                                      height: 16.0,
                                    ),
                                  ),

                                  new Container(
                                    padding: new EdgeInsets.fromLTRB(3.0, 0.0, 0.0, 0.0),
                                    child: new Image.asset("mainframe_assets/images/food_a60.png",
                                      width: 16.0,
                                      height: 16.0,
                                    ),
                                  ),


                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Expanded(
                        //padding: const EdgeInsets.all(5.0),
                        child: new Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          decoration: new BoxDecoration(
                            borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                            border: new Border.all(
                              width: 2.0,
                              color: const Color(0xFF313746),
                              style: BorderStyle.solid,
                            ),
                            //color: Colors.green
                          ),
                          height: 40.0,
                          //color: Colors.green,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text("Total", style: new TextStyle(color: const Color(0xFF778198))),
                              new Text("21", style: new TextStyle(color: const Color(0xFF313746), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                new Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Divider(color: Colors.black, height: 16.0)
                ),

                new Flexible(
                    child: new ListView(
                      children: <Widget>[
                        new Column(
                          children: <Widget>[
                            new Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 0.0),
                              child: new Text("John has existing dance entries on this session. an admission ticket is required:", textAlign: TextAlign.justify,),
                            ),

                            new Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                //color: Colors.amber,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[

                                    new Container(
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
                                              padding: const EdgeInsets.all(0.0),
                                              minWidth: 2.0, height: 5.0,
                                              color: const Color(0xFFC5CDDF),
                                              onPressed: (){},
                                              child: new Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                                child: new Icon(Icons.remove, size: 18.0),
                                              ),
                                          ),
                                          new MaterialButton(
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: Colors.white,
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.add, size: 18.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      width: 25.0,
                                      alignment: Alignment.centerRight,
                                      child: new Text("11"),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: new Text("GENERAL ADMISSION", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                    ),
                                    new Expanded(
                                        child: new Container(
                                          //color: Colors.cyan,
                                          alignment: Alignment.centerRight,
                                          child: new Text("\$20"),
                                        )
                                    )
                                  ],
                                )
                            ),

                            new Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                //color: Colors.amber,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[

                                    new Container(
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
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: const Color(0xFFC5CDDF),
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.remove, size: 18.0),
                                            ),
                                          ),
                                          new MaterialButton(
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: Colors.white,
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.add, size: 18.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      width: 25.0,
                                      alignment: Alignment.centerRight,
                                      child: new Text("1"),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: new Text("STANDING ROOM", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                    ),
                                    new Expanded(
                                        child: new Container(
                                          //color: Colors.cyan,
                                          alignment: Alignment.centerRight,
                                          child: new Text("\$25"),
                                        )
                                    )
                                  ],
                                )
                            ),

                            new Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                //color: Colors.amber,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[

                                    new Container(
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
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: const Color(0xFFC5CDDF),
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.remove, size: 18.0),
                                            ),
                                          ),
                                          new MaterialButton(
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: Colors.white,
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.add, size: 18.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      width: 25.0,
                                      alignment: Alignment.centerRight,
                                      child: new Text("1"),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: new Text("RISERS", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                    ),
                                    new Expanded(
                                        child: new Container(
                                          //color: Colors.cyan,
                                          alignment: Alignment.centerRight,
                                          child: new Text("\$35"),
                                        )
                                    )
                                  ],
                                )
                            ),

                            new Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                //color: Colors.amber,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[

                                    new Container(
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
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: const Color(0xFFC5CDDF),
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.remove, size: 18.0),
                                            ),
                                          ),
                                          new MaterialButton(
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: Colors.white,
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.add, size: 18.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      width: 25.0,
                                      alignment: Alignment.centerRight,
                                      child: new Text("0"),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: new Text("2ND ROW TABLES", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                    ),
                                    new Expanded(
                                        child: new Container(
                                          //color: Colors.cyan,
                                          alignment: Alignment.centerRight,
                                          child: new Text("\$55"),
                                        )
                                    )
                                  ],
                                )
                            ),

                            new Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                //color: Colors.amber,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[

                                    new Container(
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
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: const Color(0xFFC5CDDF),
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.remove, size: 18.0),
                                            ),
                                          ),
                                          new MaterialButton(
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: Colors.white,
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.add, size: 18.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      width: 25.0,
                                      alignment: Alignment.centerRight,
                                      child: new Text("0"),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: new Text("1ST ROW TABLES", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                    ),
                                    new Expanded(
                                        child: new Container(
                                          //color: Colors.cyan,
                                          alignment: Alignment.centerRight,
                                          child: new Text("\$65"),
                                        )
                                    )
                                  ],
                                )
                            ),

                            new Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                //color: Colors.amber,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[

                                    new Container(
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
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: const Color(0xFFC5CDDF),
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.remove, size: 18.0),
                                            ),
                                          ),
                                          new MaterialButton(
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: Colors.white,
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.add, size: 18.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      width: 25.0,
                                      alignment: Alignment.centerRight,
                                      child: new Text("0"),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: new Text("VIP TABLE", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                    ),
                                    new Expanded(
                                        child: new Container(
                                          //color: Colors.cyan,
                                          alignment: Alignment.centerRight,
                                          child: new Text("\$115"),
                                        )
                                    )
                                  ],
                                )
                            ),

                            new Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                //color: Colors.amber,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[

                                    new Container(
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
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: const Color(0xFFC5CDDF),
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.remove, size: 18.0),
                                            ),
                                          ),
                                          new MaterialButton(
                                            padding: const EdgeInsets.all(0.0),
                                            minWidth: 2.0, height: 5.0,
                                            color: Colors.white,
                                            onPressed: (){},
                                            child: new Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                              child: new Icon(Icons.add, size: 18.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      width: 25.0,
                                      alignment: Alignment.centerRight,
                                      child: new Text("1"),
                                    ),

                                    new Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: new Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text("VIP ENTIRE TABLE", style: new TextStyle(fontSize: 14.0, color: const Color(0xff00b2cc))),
                                          new Text("(SEATS 8)", style: new TextStyle(fontSize: 12.0, color: const Color(0xff00b2cc))),
                                        ],
                                      ),
                                    ),
                                    new Expanded(
                                        child: new Container(
                                          //color: Colors.cyan,
                                          alignment: Alignment.centerRight,
                                          child: new Text("\$825"),
                                        )
                                    )
                                  ],
                                )
                            ),

                            new Container(
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                child: new Divider(color: Colors.black, height: 16.0)
                            ),
                            
                            new Center(
                              child: new RichText(
                                  text: new TextSpan(
                                    text: "Session Total",
                                    style: new TextStyle(color: const Color(0xff00b2cc)),
                                    children: <TextSpan>[
                                      new TextSpan(
                                        text: " - \$1105",
                                        style: new TextStyle(color: Colors.black)
                                      )
                                    ]
                                  )
                              ),
                            ),

                            new Center(
                              child: new Container(
                                width: 112.0,
                                margin: const EdgeInsets.symmetric(vertical: 5.0),
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
                                        child: new Text("CANCEL"),
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
                                        child: new Text("OK"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    )
                ),
              ],
            ),
          )
        ],
      ),
    )
  );
}

/*
  A method that shows a dialog screen with cancel option.
  It accepts a String message and a string title
 */
Future<String> showMainFrameDialogWithCancel(BuildContext context, String title, String msg) async {

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // user must tap button!
    child: new AlertDialog(
      title: new Text(title),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text(msg)
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('NO'),
          onPressed: () {
            Navigator.pop(context, "CANCEL");
          },
        ),
        new FlatButton(
          child: new Text('YES'),
          onPressed: () {
            Navigator.pop(context, "OK");
          },
        ),
      ],
    ),
  ).then((val){
    return val;
  });
}

/*
  A method that shows a dialog screen
  the dialog contains a selection of Age categories
 */
Future<dynamic> showAgeCategoryDialog(BuildContext context, bool hasCat, List<String> _agesTextArr, _selectedButtons, VoidCallback onComplete, {List<int> ages}) async {
  List<String> _agesText = <String>[
    "J1 up to 8", "J2 8 to 12",
    "Youth 16 to 18", "Teen 13 to 15",
    "A1 18 to 35", "A2 36 to 50", "B1 51 to 65"
  ];
  bool hasErrors = false;

  if(_agesTextArr?.length != null && _agesTextArr.length > 0) {
    _agesText = [];
    _agesText.addAll(_agesTextArr);
  }
  List<String> _enabledAges = [];

  if(ages != null && ages.length > 0) {
    ages.forEach((f){
      if(f <= 8) {
        // J1 up to 8
        _enabledAges.add("J1 up to 8");
      } else if(f <= 12 && f >= 8) {
        // J2 8 to 12
        _enabledAges.add("J2 8 to 12");
      } else if(f <= 18 && f >= 16) {
        // Youth 16 to 18
        _enabledAges.add("Youth 16 to 18");
      } else if(f <= 15 && f >= 13) {
        // Teen 13 to 15
        _enabledAges.add("Teen 13 to 15");
      } else if(f <= 35 && f >= 18) {
        // A1 18 to 35
        _enabledAges.add("A1 18 to 35");
      } else if(f <= 50 && f >= 36) {
        // A2 36 to 50
        _enabledAges.add("A2 36 to 50");
      } else if(f <= 65 && f >= 51) {
        // B1 51 to 65
        _enabledAges.add("B1 51 to 65");
      }
    });
  } else {
    _enabledAges = _agesText;
  }

  List<Widget> _ages = <Widget>[];
  Widget _catOpenClose = new Container();

  _ages.addAll(_agesText.map((str) {
    bool _openVal = false;
    bool _closedVal = false;
    //print("$str ${_selectedButtons}");
    FormAgeCat _fAgeCat = _selectedButtons[str];

    if(_fAgeCat != null) {
      _openVal = _fAgeCat.catOpen;
      _closedVal = _fAgeCat.catClosed;
    }

    if(hasCat) {
      Widget _errMsg = new Container();

      if(_enabledAges.contains(str)) {
        if (_selectedButtons.containsKey(str)) {
          FormAgeCat _formAgeCat = _selectedButtons[str];
          //print("Open: ${_formAgeCat.catOpen} closed: ${_formAgeCat.catClosed}");
          if(!_formAgeCat.catOpen && !_formAgeCat.catClosed) {
            _errMsg = new Container(
              margin: const EdgeInsets.only(bottom: 2.0),
              child: new Text("Select Open/Closed", style: new TextStyle(fontSize: 13.0, color: Colors.red)),
            );
            hasErrors = true;
          }
        }
      }

      Checkbox _tempOpen = new Checkbox(activeColor: const Color(0xFF324261),value: _openVal,
          onChanged: (bool val){
            //_openVal=val;
            if(_enabledAges.contains(str)) {
              FormAgeCat _formAgeCat;
              if (!_selectedButtons.containsKey(str)) {
                _selectedButtons.putIfAbsent(str, () => new FormAgeCat());
                _formAgeCat = _selectedButtons[str];
                _formAgeCat.catOpen = !_formAgeCat.catOpen;
              }
              else {
                _formAgeCat = _selectedButtons[str];
                _formAgeCat.catOpen = !_formAgeCat.catOpen;
                if(!_formAgeCat.catOpen && !_formAgeCat.catClosed) {
                  _selectedButtons.remove(str);
                  print("STR: $str");
                  print("BOTH REMOVED");
                }
              }
              Navigator.of(context).pop();
              showAgeCategoryDialog(context, hasCat, _agesTextArr, _selectedButtons, onComplete, ages: ages);
            }
          }
      );

      Checkbox _tempClosed = new Checkbox(activeColor: const Color(0xFF324261),value: _closedVal,
          onChanged: (bool val){
            if(_enabledAges.contains(str)) {
              FormAgeCat _formAgeCat;
              if (!_selectedButtons.containsKey(str)) {
                _selectedButtons.putIfAbsent(str, () => new FormAgeCat());
                _formAgeCat = _selectedButtons[str];
                _formAgeCat.catClosed = !_formAgeCat.catClosed;
              }
              else {
                _formAgeCat = _selectedButtons[str];
                _formAgeCat.catClosed = !_formAgeCat.catClosed;
                if(!_formAgeCat.catOpen && !_formAgeCat.catClosed) {
                  _selectedButtons.remove(str);
                  print("STR: $str");
                  print("BOTH REMOVED");
                }
              }
              Navigator.of(context).pop();
              showAgeCategoryDialog(context, hasCat, _agesTextArr, _selectedButtons, onComplete, ages: ages);
            }
          }
      );

      _catOpenClose = new Expanded(
        child: new Column(
          children: <Widget>[
            _errMsg,
            new Container(
              height: 20.0,
              child: new Row(
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(right: 5.0),
                    child: new InkWell(
                      onTap: () {
                        print("tapped open ${_tempOpen.value}");
                        _tempOpen.onChanged(!_tempOpen.value);
                      },
                      child: new Row(
                        children: <Widget>[
                          new Container(
                              width: 15.0,
                              margin: const EdgeInsets.only(right: 5.0),
                              //color: Colors.amber,
                              child: _tempOpen
                          ),
                          new Text("Open"),
                        ],
                      ),
                    )
                  ),
                  new Container(
                    child: new InkWell(
                      onTap: () {
                        print("tapped closed ${_tempClosed.value}");
                        _tempClosed.onChanged(!_tempClosed.value);
                      },
                      child: new Row(
                        children: <Widget>[
                          new Container(
                              width: 15.0,
                              margin: const EdgeInsets.only(right: 5.0),
                              //color: Colors.amber,
                              child: _tempClosed
                          ),
                          new Text("Closed"),
                        ],
                      ),
                    )
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }


    return new Row(
      children: <Widget>[
        new Expanded(
            child: new MaterialButton(
                padding: const EdgeInsets.all(5.0),
                onPressed: (){
                  if(_enabledAges.contains(str)) {
                    if (_selectedButtons.containsKey(str)) {
                      _selectedButtons.remove(str);
                    } else {
                      _selectedButtons.putIfAbsent(str, () => new FormAgeCat());
                    }
                    Navigator.of(context).pop();
                    showAgeCategoryDialog(context, hasCat, _agesTextArr, _selectedButtons, onComplete, ages: ages);
                  }
                },
                child: new Container(
                  decoration: new BoxDecoration(
                    borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                    color: _selectedButtons.containsKey(str) ? new Color(0xff249A9E) : (_enabledAges.contains(str) ? new Color(0xff335577) : new Color(0xff556c8f)),
                    //color: _filteredColor(str, _selectedButtons, _enabledAges)
                    /*image: new DecorationImage(
                  image: new ExactAssetImage("mainframe_assets/images/age_modal_btn.png"),
                  fit: BoxFit.cover,
              )*/
                  ),
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: new Center(child: new Text(str)),
                  alignment: Alignment.centerLeft,
                )
            ),
        ),
        _catOpenClose
      ],
    );
  }).toList());

  double heightOverflow = 345.0;
  if(MediaQuery.of(context).orientation == Orientation.landscape) {
    heightOverflow = 260.0;
  }

  return showDialog<Null>(
    context: context,
    //barrierDismissible: false,
    child: new Dialog(
      child: new Container(
        decoration: new BoxDecoration(
            borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
            color: new Color(0xff364864),
            boxShadow: <BoxShadow>[
              new BoxShadow(
                blurRadius: 1.0,
                spreadRadius: 1.0
              )
            ]
        ),
        height: 390.0,
        width: 180.0,
        child: new Column(
          children: <Widget>[
            new Container(
              //color: Colors.amber,
              height: 45.0,
              child: new Row(
                children: <Widget>[
                  new Container(
                      margin: const EdgeInsets.only(left: 5.0),
                      child: new InkWell(
                        onTap: (){
                          _selectedButtons = {};
                          Navigator.of(context).pop();
                        },
                        child: new Icon(Icons.arrow_back_ios),
                      )
                  ),
                  new Flexible(
                      child: new Center(
                        child: new Text(hasCat ? "SELECT AGE/CATEGORY" : "SELECT AGE", overflow: TextOverflow.ellipsis, style: new TextStyle(fontSize: 16.0)),
                      )
                  ),
                  new InkWell(
                    onTap: () {
                      if(!hasErrors) {
                        Navigator.of(context).pop();
                        onComplete();
                      }
                    },
                    child: new Container(
                      margin: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
                      height: 80.0,
                      constraints: const BoxConstraints(maxWidth: 45.0),
                      decoration: new BoxDecoration(
                          borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                          color: new Color(0xff335577)
                      ),
                      child: new Text("OK", style: new TextStyle(fontWeight: FontWeight.bold)),
                      alignment: Alignment.center,
                    ),
                  )
                ],
              ),
            ),
            new Expanded(
              //color: Colors.amber,
              //height: heightOverflow,
              child: new ListView(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Expanded(
                          child: new Container(
                            width: 155.0,
                            constraints: const BoxConstraints(minWidth: 55.0),
                            child: new Column(
                              children: _ages,
                            ),
                          )
                      ),
                      /*new Expanded(
                        child: new Row(
                          children: <Widget>[
                            new Container(
                              margin: const EdgeInsets.only(right: 5.0),
                              child: new Row(
                                children: <Widget>[
                                  new Container(
                                    width: 15.0,
                                    margin: const EdgeInsets.only(right: 5.0),
                                    //color: Colors.amber,
                                    child: new Checkbox(activeColor: const Color(0xFF324261),value: _openVal,
                                        onChanged: (bool val){
                                          _openVal=val;
                                        }),
                                  ),
                                  new Text("Open"),
                                ],
                              ),
                            ),
                            new Container(
                              child: new Row(
                                children: <Widget>[
                                  new Container(
                                    width: 15.0,
                                    margin: const EdgeInsets.only(right: 5.0),
                                    //color: Colors.amber,
                                    child: new Checkbox(activeColor: const Color(0xFF324261),value: _closedVal,
                                        onChanged: (bool val){
                                          _closedVal = val;
                                        }),
                                  ),
                                  new Text("Closed"),
                                ],
                              ),
                            ),
                          ],
                        ),
                        //color: Colors.amber,
                        /*child: new Column(
                          children: <Widget>[
                            new Container(
                              child: new MaterialButton(
                                  padding: const EdgeInsets.all(5.0),
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                    onComplete();
                                  },
                                  child: new Container(
                                    height: 80.0,
                                    decoration: new BoxDecoration(
                                        borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                                        color: new Color(0xff335577)
                                    ),
                                    /*child: new Column(
                                      children: <Widget>[
                                        //new Text("+", style: new TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
                                        new Icon(Icons.check),
                                        new Text("OK")
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),*/
                                    child: new Text("OK", style: new TextStyle(fontWeight: FontWeight.bold)),
                                    alignment: Alignment.center,
                                  )
                              ),
                            ),
                            /*new Container(
                              child: new MaterialButton(
                                  padding: const EdgeInsets.all(5.0),
                                  onPressed: () {
                                    _selectedButtons = <String>[];
                                    Navigator.of(context).pop();
                                  },
                                  child: new Container(
                                    height: 80.0,
                                    decoration: new BoxDecoration(
                                        borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                                        color: new Color(0xff335577)
                                    ),
                                    child: new Column(
                                      children: <Widget>[
                                        new Text("x", style: new TextStyle(fontSize: 30.0)),
                                        new Text("CANCEL", style: new TextStyle(fontSize: 12.0))
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),
                                    alignment: Alignment.center,
                                  )
                              ),
                            )*/
                          ],
                        )*/
                      )*/
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  )
                ],
              ),
            )
          ],
        )
      ),
    )
  );
}
