import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/MFTabComponent.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/widget/MFButton.dart';

var eventItem;

class EventDetails extends StatefulWidget {
  @override
  _EventDetailsState createState() => new _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  DateFormat format = new DateFormat("MMM dd, yyyy");
  String eventTitle = "EVENT TITLE";
  String eventRange = "";

  @override
  void initState() {
    super.initState();
    if(eventItem != null) {
      eventTitle = eventItem.eventTitle;
      eventRange = eventItem.dateRange;
    }
  }

  Widget _buildEventInfo() {
    return new Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text("Event:  $eventTitle", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),
            new Text("When:  ${format.format(eventItem.startDate)} to ${format.format(eventItem.stopDate)}", style: new TextStyle(fontSize: 16.0)),
            new Padding(padding: const EdgeInsets.only(top: 10.0)),
            new Text("Status:  ${eventItem.statusName}", style: new TextStyle(fontSize: 16.0)),
          ],
        ),
    );
  }

  Widget _buildVenueInfo() {
    return new Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text("Venue:  ${eventItem.venue.venueName}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Address:  ${eventItem.venue.address}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Province:  ${eventItem.venue.province}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("City:  ${eventItem.venue.city} ${eventItem.venue.zip}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Country:  ${eventItem.venue.country}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Phone:  ${eventItem.venue.phone}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Fax:  ${eventItem.venue.fax}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Web:  ${eventItem.venue.website}", style: new TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return new Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text("Address:  ${eventItem.contact.address}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Province:  ${eventItem.contact.province}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("City:  ${eventItem.contact.city} ${eventItem.venue.zip}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Country:  ${eventItem.contact.country}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Phone:  ${eventItem.contact.phone}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Fax:  ${eventItem.contact.fax}", style: new TextStyle(fontSize: 16.0)),
          new Padding(padding: const EdgeInsets.only(top: 10.0)),
          new Text("Email:  ${eventItem.contact.email}", style: new TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }

  Widget _buildOrganizers() {
    List<Widget> _organizerChildren = [];

    eventItem.organizers.forEach((itm){
      _organizerChildren.add(new Text("Name:  ${eventItem.contact.address}", style: new TextStyle(fontSize: 16.0)));
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

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/add_via_email.png";

    return new Scaffold(
      appBar: new MFAppBar(eventTitle, context),
      body: new Column(
        children: <Widget>[
          //new Expanded(
              /*child:*/ new Container(
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new ExactAssetImage("mainframe_assets/images/m7x5ba.jpg"),
                        fit: BoxFit.cover
                    )
                ),
                child: new Container(
                  height: 55.0,
                  width: 300.0,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(eventTitle, style: new TextStyle(fontSize: 22.0)),
                      new Text(eventRange, style: new TextStyle(fontSize: 16.0, color: new Color(0xff00e5ff)))
                    ],
                  )
                ),
                height: 235.0,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
              ),
          //),
          new Flexible(
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
          )
        ],
      ),
      floatingActionButton: new InkWell(
        onTap: (){},
        child: new Container(
          //color: Colors.amber,
          width: 100.0,
          height: 40.0,
          alignment: Alignment.center,
          decoration: new BoxDecoration(
            image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
          ),
          child: new Text("Register"),
        ),
      )
    );
  }
}