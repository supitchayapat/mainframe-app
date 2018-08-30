import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/widget/MFPageSelector.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/screen/event_registration.dart' as eventInfo;
import 'package:myapp/MFGlobals.dart' as global;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/src/dao/ResultsDao.dart';
import 'package:myapp/src/dao/HeatlistDao.dart';
import 'package:myapp/src/dao/UserDao.dart';

var eventItem;
var heatResult;
var heatList;
var selectedParticipant;

class EventDetails extends StatefulWidget {
  @override
  _EventDetailsState createState() => new _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  DateFormat format = new DateFormat("MMM d, yyyy");
  final formatterOut = new DateFormat("MMM d");
  String eventTitle = "EVENT TITLE";
  String eventRange = "";
  bool isRegisterOpen = false;
  List _solo = [];
  List _couples = [];
  Map<String, dynamic> _users = {};
  var soloListener;
  var coupleListener;

  void _processResults(res) {
    if(res != null) {
      coupleParticipantsListener((couples) {
        setState(() {
          _users = {};
          _couples = [];
          _couples.addAll(couples);
          _solo.forEach((val) {
            _users.putIfAbsent(
                "${val.first_name} ${val.last_name}", () => val);
          });
          couples.forEach((val) {
            for (var cp in res.couples) {
              // check if matches coupleKey and Names
              if (cp.coupleKey == val.key)
                _users.putIfAbsent("${val.coupleName}", () => val);
            }
          });
        });

        //print("users: ${_users.length}");
      }).then((listener) {
        coupleListener = listener;
      });
    }
  }

  @override
  void initState() {
    heatList = null;
    heatResult = null;
    super.initState();

    // logging for crashlytics
    global.messageLogs.add("[${eventItem?.eventTitle}] Event Details Page Load.");
    AnalyticsUtil.setCurrentScreen("Event Details", screenClassName: "event_details");

    if(eventItem != null) {
      eventTitle = eventItem.eventTitle;
      //eventRange = eventItem.dateRange;
      if(eventItem.dateStart == eventItem.dateStop) {
        eventRange = "${formatterOut.format(eventItem.dateStart)}";
      } else {
        eventRange = "${formatterOut.format(eventItem.dateStart)} - ${formatterOut.format(eventItem.dateStop)}";
      }
    }

    // check if registration is open
    isRegisterOpen = eventItem.uberRegister;

    // heat results
    HeatListDao.getHeats(eventItem.evtPId).then((res){
      heatList = res;
      _processResults(res);
    });

    // heat results
    ResultsDao.getResults(eventItem.evtPId).then((res){
      heatResult = res;

      // pull participants
      /*soloParticipantsListener((users){
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
      }).then((listener) {soloListener=listener;});*/
      _processResults(res);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if(soloListener != null)
      soloListener.cancel();
    if(coupleListener != null)
      coupleListener.cancel();
  }

  Future _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //throw 'Could not launch $url';
      showMainFrameDialog(context, "Website URL", "Could not launch $url");
    }
  }

  Widget _buildEventInfo() {
    bool displayUrl = true;

    if(global.devicePlatform == "ios" && ((global.currentUserProfile?.ao != null && !global.currentUserProfile?.ao) || global.currentUserProfile?.ao == null)) {
      displayUrl = false;
    }

    return new Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*new Text("Event:  $eventTitle", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),
            new Text("${format.format(eventItem.dateStart)} to ${format.format(eventItem.dateStop)}", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),
            new Text("Status:  ${eventItem.statusName}", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),*/
            new Text("Registration deadline:  ${eventItem.deadline != null ? format.format(eventItem.deadline) : ""}", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),
            (displayUrl) ? new Wrap(
              children: <Widget>[
                new Text("Website:  ", style: new TextStyle(fontSize: 16.0)),
                new InkWell(
                  onTap: (){
                    global.messageLogs.add("Website link tapped. Navigate to ${eventItem?.website}");
                    AnalyticsUtil.sendAnalyticsEvent("navigate_web", params: {
                      'screen': 'event_details'
                    });
                    if(eventItem?.website != null) {
                      if((eventItem?.website).contains("http") || (eventItem?.website).contains("https"))
                        _launchUrl(eventItem?.website);
                      else
                        _launchUrl("http://${eventItem?.website}");
                    }
                  },
                  child: new Wrap(
                    children: <Widget>[
                      new Text("${eventItem?.website}", style: new TextStyle(fontSize: 14.0, color: new Color(0xff00e5ff), decoration: TextDecoration.underline)),
                      new Padding(padding: const EdgeInsets.only(left: 5.0), child: new Icon(FontAwesomeIcons.externalLinkAlt, color: new Color(0xff00e5ff), size: 16.0))
                    ],
                  ),
                )
              ],
            ) : new Container()
          ],
        ),
    );
  }

  List<Widget> _addIfNotEmpty(prop, {label, padTop}) {
    List<Widget> _children = [];
    if(prop != null && prop != "") {
      if(label == null || label.toString().isEmpty) {
        _children.addAll([
          new Container(
            padding: (padTop != null) ? const EdgeInsets.only(top: 10.0) : const EdgeInsets.only(),
            child: new Text("${prop}", style: new TextStyle(fontSize: 16.0)),
          )
        ]);
      } else {
        _children.addAll([
          new Container(
            padding: (padTop != null) ? const EdgeInsets.only(top: 10.0) : const EdgeInsets.only(),
            child: new Text("$label:  ${prop}", style: new TextStyle(fontSize: 16.0)),
          )
        ]);
      }
    }
    return _children;
  }

  Widget _buildVenueInfo() {
    //print("build venue");
    List<Widget> _children = [];

    _children.addAll(_addIfNotEmpty(eventItem?.venue?.venueName));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.address));
    //_children.addAll(_addIfNotEmpty(eventItem?.venue?.province));
    //print("province: ${eventItem.venue.province}");
    //print("city: ${eventItem.venue.city}");
    //print("zip: ${eventItem.venue.zip}");
    if((eventItem?.venue?.province != null && eventItem.venue.province != "") && (eventItem?.venue?.city != null && eventItem.venue.city != "")) {
      _children.addAll(_addIfNotEmpty("${eventItem.venue.city}, ${eventItem.venue.province}"));
    } else {
        _children.addAll(_addIfNotEmpty(eventItem?.venue?.city));
        _children.addAll(_addIfNotEmpty(eventItem?.venue?.province));
    }
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.zip));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.country));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.phone, label: "Phone", padTop: true));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.fax, label: "Fax"));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.website, label: "website", padTop: true));

    return new Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _children,
      ),
    );
  }

  Widget _buildContactInfo() {
    List<Widget> _children = [];

    _children.addAll(_addIfNotEmpty(eventItem?.contact?.address));
    //_children.addAll(_addIfNotEmpty(eventItem?.contact?.province));
    //print("contact province: ${eventItem.contact.province}");
    //print("contact city: ${eventItem.contact.city}");
    //print("contact zip: ${eventItem.contact.zip}");
    if((eventItem?.contact?.province != null && eventItem.contact.province != "") && (eventItem?.contact?.city != null && eventItem.contact.city != "")) {
      _children.addAll(_addIfNotEmpty("${eventItem.contact.city}, ${eventItem.contact.province}"));
    } else {
        _children.addAll(_addIfNotEmpty(eventItem?.contact?.city));
        _children.addAll(_addIfNotEmpty(eventItem?.contact?.province));
    }
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.zip));
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.country));
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.phone, label: "Phone", padTop: true));
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.fax, label: "Fax"));
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.email, label: "Email", padTop: true));

    return new Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _children,
      ),
    );
  }

  Widget _buildOrganizers() {
    List<Widget> _organizerChildren = [];

    eventItem.organizers.forEach((itm){
      _organizerChildren.add(new Text("${itm}", style: new TextStyle(fontSize: 16.0)));
      _organizerChildren.add(new Padding(padding: const EdgeInsets.only(top: 10.0)));
    });

    return new Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _organizerChildren,
      ),
    );
  }

  Widget _buildSchedule() {
    List<Widget> _scheduleChildren = [];
    _scheduleChildren.add(new Center(
      child: new Text("${eventItem?.schedule?.title}", style: new TextStyle(fontSize: 18.0)),
    ));

    for(var _sched in eventItem.schedule.schedules) {
      _scheduleChildren.add(new Container(
        //color: Colors.amber,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Padding(padding: const EdgeInsets.only(bottom: 5.0), child: new Text(_sched.headerName, style: new TextStyle(fontSize: 16.0))),
            new Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: new Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _sched.timedata.map<Widget>((_timedata){
                    return new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          //color: Colors.amber,
                          //margin: const EdgeInsets.only(right: 10.0),
                          alignment: Alignment.topLeft,
                          constraints: new BoxConstraints(minWidth: 80.0),
                          child: new Text((_timedata?.timeValue != null && _timedata.timeValue.isNotEmpty) ? _timedata.timeValue : ""),
                        ),
                        new Expanded(
                            child: new Container(
                              //color: Colors.amber,
                              margin: const EdgeInsets.only(bottom: 10.0),
                              child: new Text("${_timedata.description}"),
                            ),
                        )
                      ],
                    );
                  }).toList(),
                ),
            )
          ],
        ),
      ));
    }

    return new Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _scheduleChildren,
      ),
    );
  }

  Widget _resButton(buttonText, pressedFunction) {
    return new Expanded(
      child: new Container(
        decoration: new BoxDecoration(
            borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
            border: new Border.all(
              width: 2.0,
              color: const Color(0xFF313746),
              style: BorderStyle.solid,
            )
        ),
        height: 48.0,
        constraints: new BoxConstraints(minWidth: 120.0),
        child: new MaterialButton(
          padding: new EdgeInsets.all(0.0),
          minWidth: 5.0, height: 5.0,
          color: const Color(0xFFF4EEF6),
          onPressed: pressedFunction,
          child: new Text(buttonText,
            style: new TextStyle(
                fontSize: 18.0,
                color: const Color(0xFF287399)
            ),
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/add_via_email.png";
    DateTime _now = new DateTime.now();
    String _floatText = "Register";
    List<Widget> _btnChildren = [];

    Widget _btnWidget = _resButton(_now.isAfter(eventItem.dateStop) ? "Results" : "Register", (){
      global.messageLogs.add("Register button tapped.");
      AnalyticsUtil.sendAnalyticsEvent("register_btn_press", params: {
        'screen': 'event_details'
      });
      eventInfo.eventItem = eventItem;
      eventInfo.participant = null;
      if(_floatText == "Register") {
        if(isRegisterOpen) {
          Navigator.of(context).pushNamed("/registration");
        } else {
          showMainFrameDialogWithCancel(
              context,
              "Registration Status",
              "Mobile Registration is not currently available for this Competition. Would you instead wish to go to their website now?"
          ).then((ans) {
            if(ans == "OK") {
              if(eventItem?.website != null) {
                if((eventItem?.website).contains("http") || (eventItem?.website).contains("https"))
                  _launchUrl(eventItem?.website);
                else
                  _launchUrl("http://${eventItem?.website}");
              }
            }
          });
        }
      }
      else if(_floatText == "Results") {
        selectedParticipant = null;

        Map<String, dynamic> participantsList = {};
        _users.forEach((_usrName, _usr){
          participantsList.putIfAbsent(_usrName, () => _usr);
        });
        participantsList.putIfAbsent("All Participants", () => "all");

        showSelectionDialog(context, "SELECT PARTICIPANT", 220.0,
            participantsList).then((selectVal){
          if(selectVal != null) {
            // navigate results
            if(selectVal == "all" && heatResult != null) {
              //print("Evt PID: ${eventItem.evtPId}");
              Navigator.of(context).pushNamed("/result");
            }
            else {
              selectedParticipant = selectVal;
              Navigator.of(context).pushNamed("/result");
            }
          }
        });
      }
    });

    /*Widget _btnWidget = new InkWell(
      onTap: (){},
      child: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
          //color: Colors.amber
        ),
        width: 115.0,
        height: 40.0,
        child: new Center(child: new Text(_now.isAfter(eventItem.dateStop) ? "Results" : "Register", style: new TextStyle(fontSize: 17.0))),
      ),
    );*/

    if(_now.isAfter(eventItem.dateStop)) {
      _floatText = "Results";
      _btnChildren.add(
        _btnWidget
      );

      if(heatList != null) {
        _btnChildren.add(
            _resButton("Heat List", () {
              selectedParticipant = null;
              Navigator.of(context).pushNamed("/heatlist");
            })
        );
      } else {
        _btnChildren.add(
            new Expanded(
                child: new Container()
            )
        );
      }
    }
    else {
      if(heatList != null) {
        _btnChildren.add(
            _resButton("Heat List", () {
              selectedParticipant = null;
              Navigator.of(context).pushNamed("/heatlist");
            })
        );
      } else {
        _btnChildren.add(
            new Expanded(
                child: new Container()
            )
        );
      }
      _btnChildren.add(_btnWidget);
    }

    List<PageSelectData> _pages = [];
    _pages.add(new PageSelectData(
        tabName: 'Event',
        description: '',
        demoWidget: _buildEventInfo(),
        loadMoreCallback: (){}
    ));

    if(eventItem?.schedule != null) {
      _pages.add(new PageSelectData(
          tabName: 'Schedule',
          description: '',
          demoWidget: _buildSchedule(),
          loadMoreCallback: (){}
      ));
    }

    if(eventItem?.venue != null) {
      _pages.add(new PageSelectData(
          tabName: 'Location of Event',
          description: '',
          demoWidget: _buildVenueInfo(),
          loadMoreCallback: (){}
      ));
    }

    if(eventItem?.contact != null) {
      _pages.add(new PageSelectData(
          tabName: 'Contact Info',
          description: '',
          demoWidget: _buildContactInfo(),
          loadMoreCallback: (){}
      ));
    }

    if(eventItem?.organizers != null) {
      _pages.add(new PageSelectData(
          tabName: 'Organizer',
          description: '',
          demoWidget: _buildOrganizers(),
          loadMoreCallback: (){}
      ));
    }

    return new Scaffold(
      appBar: new MFAppBar(eventTitle, context),
      body: new Column(
        children: <Widget>[
          new Expanded(
              child: new Container(
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new ExactAssetImage("mainframe_assets/images/m7x5ba.jpg"),
                        fit: BoxFit.cover
                    )
                ),
                //color: Colors.amber,
                child: new Container(
                  alignment: Alignment.bottomLeft,
                  //color: Colors.amber,
                  //height: 55.0,
                  width: 300.0,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new Container(child: new Text(eventTitle, style: new TextStyle(fontSize: 22.0))),
                      new Text("$eventRange ${eventItem.year}", style: new TextStyle(fontSize: 16.0, color: new Color(0xff00e5ff)))
                    ],
                  )
                ),
                height: 235.0,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
              ),
          ),
          new Flexible(
              child: new MFPageSelector(pageWidgets: _pages)
          )
          /*new Flexible(
              child: new MFTabbedComponentDemoScaffold(
                demos: <MFComponentDemoTabData>[
                  new MFComponentDemoTabData(
                      tabName: 'Event',
                      description: '',
                      demoWidget: _buildEventInfo(),
                      loadMoreCallback: (){}
                  ),
                  new MFComponentDemoTabData(
                      tabName: 'Venue',
                      description: '',
                      demoWidget: _buildVenueInfo(),
                      loadMoreCallback: (){}
                  ),
                  new MFComponentDemoTabData(
                      tabName: 'Contact Info',
                      description: '',
                      demoWidget: _buildContactInfo(),
                      loadMoreCallback: (){}
                  ),
                  new MFComponentDemoTabData(
                      tabName: 'Organizer',
                      description: '',
                      demoWidget: _buildOrganizers(),
                      loadMoreCallback: (){}
                  ),
                ],
              )
          )*/
        ],
      ),
      /*floatingActionButton: new InkWell(
        onTap: (){
          eventInfo.eventItem = eventItem;
          eventInfo.participant = null;
          if(_floatText == "Register") {
            if(isRegisterOpen) {
              Navigator.of(context).pushNamed("/registration");
            } else {
              showMainFrameDialogWithCancel(
                  context,
                  "Registration Status",
                  "Mobile Registration is not currently available for this Competition. Would you instead wish to go to their website now?"
              ).then((ans) {
                if(ans == "OK") {
                  if(eventItem?.website != null) {
                    if((eventItem?.website).contains("http") || (eventItem?.website).contains("https"))
                      _launchUrl(eventItem?.website);
                    else
                      _launchUrl("http://${eventItem?.website}");
                  }
                }
              });
            }
          }
        },
        child: new Container(
          //color: Colors.amber,
          width: 100.0,
          height: 40.0,
          alignment: Alignment.center,
          decoration: new BoxDecoration(
            image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
            color: Colors.amber
          ),
          child: new Text(_floatText, style: new TextStyle(fontSize: 17.0)),
        ),
      )*/
      bottomNavigationBar: new Container(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: new Container(
          padding: const EdgeInsets.only(left: 10.0, right: 5.0, top: 2.0, bottom: 5.0),
          height: 40.0,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _btnChildren,
          ),
        ),
      ),
    );
  }
}