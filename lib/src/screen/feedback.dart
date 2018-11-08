import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/dao/FeedbackDao.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/dao/ConfigDao.dart';

/*
  If user opt out to send via email. Still save on FeedbackDao with
  message 'opt out via send email'

  must be separate screen
 */

class feedback extends StatefulWidget {
  @override
  _feedbackState createState() => new _feedbackState();
}

class _feedbackState extends State<feedback> {
  TextEditingController _msgCtrl = new TextEditingController();
  String userEmail = "";

  void initState() {
    super.initState();
    ConfigDao.getSupportEmail().then((email){
      userEmail = email;
    });
  }

  void sendPressed() {
    if(_msgCtrl.text != null && _msgCtrl.text != "") {
      MainFrameLoadingIndicator.showLoading(context);
      FeedbackDao.saveFeedback(_msgCtrl.text).then((val) {
        MainFrameLoadingIndicator.hideLoading(context);
        Navigator.of(context).pop();
      }).catchError((error){
        MainFrameLoadingIndicator.hideLoading(context);
        showMainFrameDialog(context, "Send Error", "Could not send Feedback. Contact Support via the link below");
      });
    } else {
      showMainFrameDialog(context, "Send Support/Feedback", "Please enter Feedback message.");
    }
  }

  Future emailPressed() async {
    if(userEmail != null && !userEmail.isEmpty) {
      var url = 'mailto:$userEmail?subject=Feedback';
      if (await canLaunch(url)) {
        MainFrameLoadingIndicator.showLoading(context);
        FeedbackDao.saveFeedback("opt out via send email").then((val) {
          MainFrameLoadingIndicator.hideLoading(context);
          Navigator.of(context).pop();
        });

        await launch(url);
      } else {
        //throw 'Could not launch $url';
        showMainFrameDialog(context, "Send Mail", "Could not open mailing url $url");
      }
    }
  }

  void openFeedback(){
    showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      child: new AlertDialog(
        title: new Text("Submit Feedback"),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                ),
                child: new TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 15,
                  style: new TextStyle(
                    color: Colors.black
                  ),
                  controller: _msgCtrl,
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 5.0),
                child: new Text("If you wish to email support. Please press email button."),
              )
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Email'),
            onPressed: () {
              emailPressed().then((val){
                Navigator.of(context).pop();
              });
            },
          ),
          new FlatButton(
            child: new Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          new FlatButton(
            child: new Text('SEND'),
            onPressed: sendPressed,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double _height = mediaQuery.size.height;
    double _formHeight = _height - 140.0;

    return new Scaffold(
        appBar: new MFAppBar("SUPPORT / FEEDBACK", context),
        body: new Form(
          child: new ListView(
            children: <Widget>[
              new Container(
                  height: _formHeight,
                  child: new Container(
                    padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                          ),
                          child: new TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 15,
                            style: new TextStyle(
                                color: Colors.black
                            ),
                            controller: _msgCtrl,
                          ),
                        ),
                        new Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(top: 15.0),
                          child: new Wrap(
                            children: <Widget>[
                              new Text("If you wish to email support. Please press this "),
                              new InkWell(
                                onTap: emailPressed,
                                child: new Text("Contact Support Link" , style: new TextStyle(fontSize: 14.0, color: new Color(0xff00e5ff), decoration: TextDecoration.underline)),
                              )
                            ],
                          )
                        )
                      ],
                    ),
                  )
              ),
              new Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                child: new MainFrameButton(
                  fontSize: 14.0,
                  child: new Text("SEND"),
                  onPressed: sendPressed,
                ),
              )
            ],
          ),
        )
    );
  }
}