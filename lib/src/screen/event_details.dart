import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFTabComponent.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/widget/MFPageSelector.dart';
import 'package:myapp/src/screen/event_registration.dart' as eventInfo;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validator/validator.dart';

var eventItem;

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

  @override
  void initState() {
    super.initState();
    if(eventItem != null) {
      eventTitle = eventItem.eventTitle;
      //eventRange = eventItem.dateRange;
      eventRange = "${formatterOut.format(eventItem.startDate)} - ${formatterOut.format(eventItem.stopDate)}";
    }

    // check if registration is open
    isRegisterOpen = eventItem.uberRegister;
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
    return new Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*new Text("Event:  $eventTitle", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),
            new Text("${format.format(eventItem.startDate)} to ${format.format(eventItem.stopDate)}", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),
            new Text("Status:  ${eventItem.statusName}", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),*/
            new Text("Registration deadline:  ${eventItem.deadline != null ? format.format(eventItem.deadline) : ""}", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),
            new Wrap(
              children: <Widget>[
                new Text("Website:  ", style: new TextStyle(fontSize: 16.0)),
                new InkWell(
                  onTap: (){
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
            )
          ],
        ),
    );
  }

  List<Widget> _addIfNotEmpty(prop, {label}) {
    List<Widget> _children = [];
    if(prop != null && prop != "") {
      if(label == null || label.toString().isEmpty) {
        _children.addAll([
          new Text("${prop}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
        ]);
      } else {
        _children.addAll([
          new Text("$label:  ${prop}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
        ]);
      }
    }
    return _children;
  }

  Widget _buildVenueInfo() {
    List<Widget> _children = [];

    _children.addAll(_addIfNotEmpty(eventItem?.venue?.venueName));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.address));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.province));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.city));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.country));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.phone, label: "Phone"));
    _children.addAll(_addIfNotEmpty(eventItem?.venue?.fax, label: "Fax"));

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
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.province));
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.city));
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.country));
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.phone, label: "Phone"));
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.fax, label: "Fax"));
    _children.addAll(_addIfNotEmpty(eventItem?.contact?.email, label: "Email"));

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
                  children: _sched.timedata.map((_timedata){
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

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/add_via_email.png";
    DateTime _now = new DateTime.now();
    String _floatText = "Register";

    if(_now.isAfter(eventItem.stopDate)) {
      _floatText = "Results";
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
          tabName: 'Venue',
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
                      new Text("$eventRange  ${eventItem.year}", style: new TextStyle(fontSize: 16.0, color: new Color(0xff00e5ff)))
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
      floatingActionButton: new InkWell(
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
                  "Mobile Registration is not currently available for this Competition. Would you instead wish to go to their website now ?"
              ).then((ans) {
                if (ans == "OK") {
                  if (isURL(eventItem?.website))
                    _launchUrl(eventItem?.website);
                  else
                    _launchUrl("https://${eventItem?.website}");
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
          ),
          child: new Text(_floatText, style: new TextStyle(fontSize: 17.0)),
        ),
      )
    );
  }
}